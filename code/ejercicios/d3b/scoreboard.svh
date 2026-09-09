// TODO(exercise d3b) -- el uvm_error que no dice nada.
//
// This is the scoreboard as it gets written the first time: it is RIGHT --it
// catches every mismatch-- and it is useless. It is the same line as the day 1
// hook, the one where the log said FAILED and the answer was in a waveform file
// that nobody had opened.
//
// Two things are asked, and both are in the Reporting section:
//
//   1. the uvm_error has to say WHICH operation failed. The log contract is in
//      the README: A and B in TWO hex digits, the name of the operation, and
//      the two results -- the one the DUT gave and the one you predicted -- in
//      FOUR hex digits each.
//   2. the comparison that PASSES also has to be printed, with the word PASS,
//      and at UVM_HIGH -- so that a normal run does not print a thousand lines
//      and a run with +UVM_VERBOSITY=UVM_HIGH shows every one of them.
//
// $sformatf is the tool for both, and the format specifiers are %02h, %s and
// %04h. The predicted value is already in predicted_result.
class scoreboard extends uvm_component;
   `uvm_component_utils(scoreboard);

   virtual vtalu_bfm bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("SCOREBOARD", "Failed to get BFM")
   endfunction : build_phase

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
         endcase

         // ovf belongs to sub and to nobody else: with 8-bit inputs and a 16-bit
         // output, neither the addition nor the multiplication can overflow.
         predicted_ovf = (bfm.op_set == sub_op) && (bfm.A < bfm.B);

         if ((bfm.op_set != no_op) && (bfm.op_set != rst_op))
            if (predicted_result != bfm.result || predicted_ovf != bfm.ovf)
               // <<< HERE >>>  the same uvm_error, saying which operation it was
               `uvm_error("SCOREBOARD", "FAILED")
            // <<< HERE >>>  and the else branch that nobody writes: the PASS, at UVM_HIGH
      end : self_checker
   endtask : run_phase
endclass : scoreboard
