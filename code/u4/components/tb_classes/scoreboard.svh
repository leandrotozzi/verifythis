// cb: class-and-build
// The scoreboard of the TB in objects, now as a uvm_component. The four steps
// --extend, register, constructor, phases-- are in the slides of the components section.
class scoreboard extends uvm_component;
   `uvm_component_utils(scoreboard);

   virtual vtalu_bfm bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // Self-sufficient: the component asks the config_db for the BFM. Before, the
   // test passed it in through the constructor, and the test had to receive it
   // only to hand it out.
   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("SCOREBOARD", "Failed to get BFM")
   endfunction : build_phase
// cb: end

   // run_phase is the only phase that is a task: the only one that consumes
   // time. UVM launches it in its own thread.
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

         // ovf belongs to sub and to nobody else: with 8-bit inputs and a 16-bit
         // output, neither the addition nor the multiplication can overflow.
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
