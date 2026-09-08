// Este componente no es parte del curso: es el que corrige el ejercicio. Mira el
// bus del DUT y se queja si pasa una operacion que no sea una multiplicacion.
class chequeo extends uvm_component;
   `uvm_component_utils(chequeo)

   virtual vtalu_bfm bfm;
   int muls = 0;
   int otras = 0;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("CHEQUEO", "Failed to get BFM")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      forever begin
         @(posedge bfm.done);
         if (bfm.op_set == mul_op) muls++;
         else begin
            otras++;
            if (otras == 1)
               `uvm_error("CHEQUEO", $sformatf(
                          "paso un %s: el test tiene que mandar solo multiplicaciones",
                          bfm.op_set.name()
                          ))
         end
      end
   endtask : run_phase

   function void report_phase(uvm_phase phase);
      if (muls < 500)
         `uvm_error("CHEQUEO", $sformatf(
                    "solo %0d multiplicaciones: el test manda 1000 operaciones", muls))
      else if (otras == 0)
         `uvm_info("CHEQUEO", $sformatf(
                   "EJERCICIO OK: %0d multiplicaciones y ninguna otra operacion", muls),
                   UVM_NONE)
   endfunction : report_phase

endclass : chequeo
