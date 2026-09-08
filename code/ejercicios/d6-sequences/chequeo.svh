// Este componente no es parte del curso: es el que corrige el ejercicio. Mira el
// bus de clase_bfm y lleva su propia cuenta, para poder cruzarla contra la que
// imprime tu sequence. No lo toques.
class chequeo extends uvm_component;
   `uvm_component_utils(chequeo)

   virtual vtalu_bfm bfm;
   int               muls = 0;
   int               otras = 0;
   shortint unsigned max = 0;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "clase_bfm", bfm))
         `uvm_fatal("CHEQUEO", "Failed to get clase_bfm")
   endfunction : build_phase

   // Muestrea en el MISMO flanco en que el driver lee bfm.result: el de bajada
   // en que done ya subio. Con el de subida se pierde la ultima operacion,
   // porque el objection se baja apenas vuelve start().
   task run_phase(uvm_phase phase);
      forever begin
         @(negedge bfm.clk);
         if (bfm.done) begin
            if (bfm.op_set == mul_op) begin
               muls++;
               if (bfm.result > max) max = bfm.result;
            end else begin
               otras++;
               if (otras == 1)
                  `uvm_error("CHEQUEO", $sformatf(
                             "paso un %s por el bus: la sequence tiene que mandar solo multiplicaciones",
                             bfm.op_set.name()))
            end
         end
      end
   endtask : run_phase

   function void report_phase(uvm_phase phase);
      `uvm_info("CHEQUEO", $sformatf("muls=%0d otras=%0d max=%0d", muls, otras, max),
                UVM_NONE)
   endfunction : report_phase

endclass : chequeo
