// Solution to the day 3 exercise -- the uvm_error that does say something.
//
// The two changes are three lines, and the whole exercise is in what they let
// you do afterwards: with this scoreboard, a failing regression is read from the
// log. With the previous one you have to reproduce it with waveforms on.
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
      string   detalle;

      forever begin : self_checker
         @(posedge bfm.done) #1;
         case (bfm.op_set)
            add_op: predicted_result = bfm.A + bfm.B;
            sub_op: predicted_result = bfm.A - bfm.B;
            and_op: predicted_result = bfm.A & bfm.B;
            xor_op: predicted_result = bfm.A ^ bfm.B;
            mul_op: predicted_result = bfm.A * bfm.B;
         endcase

         predicted_ovf = (bfm.op_set == sub_op) && (bfm.A < bfm.B);

         if ((bfm.op_set != no_op) && (bfm.op_set != rst_op)) begin
            // One string for both branches: the failure and the pass say the
            // same thing, and that is the point -- a PASS you can read is what
            // lets you find the last good operation before the one that broke.
            detalle = $sformatf("A=%02h B=%02h op=%s got=%04h exp=%04h",
                                bfm.A, bfm.B, bfm.op_set.name(),
                                bfm.result, predicted_result);

            if (predicted_result != bfm.result || predicted_ovf != bfm.ovf)
               `uvm_error("SCOREBOARD", {"FAILED: ", detalle})
            else
               `uvm_info("SCOREBOARD", {"PASS: ", detalle}, UVM_HIGH)
         end
      end : self_checker
   endtask : run_phase
endclass : scoreboard
