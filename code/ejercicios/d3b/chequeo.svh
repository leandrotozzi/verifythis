// This component is not part of the course: it is the one that grades the
// exercise. Do not touch it.
//
// It watches the same bus as the scoreboard, on the same edge, and predicts the
// same thing. It does two jobs:
//
//   1. it counts the comparisons, so run.sh can demand that the PASS line came
//      out once per operation and not once per run;
//   2. on the FIRST mismatch it prints the five values that your uvm_error has
//      to carry, in the format the README asks for. run.sh reads them from here
//      and looks for them in YOUR line.
class chequeo extends uvm_component;
   `uvm_component_utils(chequeo)

   virtual vtalu_bfm bfm;
   int               comparadas = 0;
   int               fallas = 0;
   string            primera = "";

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("CHEQUEO", "Failed to get BFM")
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

         predicted_ovf = (bfm.op_set == sub_op) && (bfm.A < bfm.B);

         if ((bfm.op_set != no_op) && (bfm.op_set != rst_op)) begin
            comparadas++;
            if (predicted_result != bfm.result || predicted_ovf != bfm.ovf) begin
               fallas++;
               if (primera == "")
                  primera = $sformatf("A=%02h B=%02h op=%s got=%04h exp=%04h",
                                      bfm.A, bfm.B, bfm.op_set.name(),
                                      bfm.result, predicted_result);
            end
         end
      end : self_checker
   endtask : run_phase

   function void report_phase(uvm_phase phase);
      `uvm_info("CHEQUEO", $sformatf("comparadas=%0d fallas=%0d", comparadas, fallas), UVM_NONE)
      if (primera != "") `uvm_info("CHEQUEO", {"primera ", primera}, UVM_NONE)
   endfunction : report_phase

endclass : chequeo
