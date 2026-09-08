// El scoreboard de la unidad 10, ahora como uvm_component. Los cuatro pasos
// --extender, registrar, constructor, fases-- estan en las slides de la 12.
class scoreboard extends uvm_component;
   `uvm_component_utils(scoreboard);

   virtual vtalu_bfm bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // Autosuficiente: la BFM se la pide el componente al config_db. Antes se la
   // pasaba el test por el constructor, y el test tenia que recibirla solo para
   // repartirla.
   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("SCOREBOARD", "Failed to get BFM")
   endfunction : build_phase

   // run_phase es la unica fase que es task: la unica que consume tiempo. UVM
   // la lanza en su propio thread.
   task run_phase(uvm_phase phase);
      shortint predicted_result;
      bit      predicted_ovf;
      forever begin : self_checker
         @(posedge bfm.done) #1;
         case (bfm.op_set)
            add_op: predicted_result = bfm.A + bfm.B;
            sub_op: predicted_result = bfm.A - bfm.B;
            and_op: predicted_result = bfm.A & bfm.B;
            xor_op: predicted_result = bfm.A ^ bfm.B;
            mul_op: predicted_result = bfm.A * bfm.B;
         endcase  // case (op_set)

         // El ovf es del sub y de nadie mas: con 8 bits de entrada y 16 de
         // salida, ni la suma ni la multiplicacion se pasan.
         predicted_ovf = (bfm.op_set == sub_op) && (bfm.A < bfm.B);

         if ((bfm.op_set != no_op) && (bfm.op_set != rst_op))
            if (predicted_result != bfm.result || predicted_ovf != bfm.ovf)
               `uvm_error("SCOREBOARD", $sformatf(
                          "FAILED: A: %0h  B: %0h  op: %s result: %0h ovf: %0b",
                          bfm.A,
                          bfm.B,
                          bfm.op_set.name(),
                          bfm.result,
                          bfm.ovf
                          ))
      end : self_checker
   endtask : run_phase
endclass : scoreboard
