// This component is not part of the course: it is the one that grades the
// exercise. It watches the clase_bfm bus and keeps its own count, so it can cross it
// against the one your sequence prints. Do not touch it.
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

   // It samples on the SAME edge the driver reads bfm.result: the falling one
   // where done already went up. With the rising one the last operation is lost,
   // because the objection drops as soon as start() returns.
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
                             "a %s went through the bus: the sequence has to send multiplications only",
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
