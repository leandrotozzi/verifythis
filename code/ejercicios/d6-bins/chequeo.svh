// This component is not part of the course: it is the one that grades the
// exercise. It watches the clase_bfm bus and counts how many times the operation of
// the bin to close went by -- FF x FF in mul_op -- so it can tell you whether you got there. Do not touch it.
class chequeo extends uvm_component;
   `uvm_component_utils(chequeo)

   virtual vtalu_bfm bfm;
   int               ops = 0;
   int               maxmul = 0;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "clase_bfm", bfm))
         `uvm_fatal("CHEQUEO", "Failed to get clase_bfm")
   endfunction : build_phase

   // Same edge on which the driver reads bfm.result: the falling one with done up.
   task run_phase(uvm_phase phase);
      forever begin
         @(negedge bfm.clk);
         if (bfm.done) begin
            ops++;
            if (bfm.op_set == mul_op && bfm.A == 8'hFF && bfm.B == 8'hFF) maxmul++;
         end
      end
   endtask : run_phase

   function void report_phase(uvm_phase phase);
      `uvm_info("CHEQUEO", $sformatf("ops=%0d maxmul=%0d", ops, maxmul), UVM_NONE)
   endfunction : report_phase

endclass : chequeo
