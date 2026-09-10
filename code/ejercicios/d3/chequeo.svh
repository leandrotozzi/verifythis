// This component is not part of the course: it is the one that grades the
// exercise. It watches the DUT bus and complains if anything but a multiplication goes by.
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
                          "a %s went by: the test has to send multiplications only",
                          bfm.op_set.name()
                          ))
         end
      end
   endtask : run_phase

   function void report_phase(uvm_phase phase);
      if (muls < 500)
         `uvm_error("CHEQUEO", $sformatf(
                    "only %0d multiplications, and at least 500 are needed", muls))
      else if (otras == 0)
         `uvm_info("CHEQUEO", $sformatf(
                   "EXERCISE OK: %0d multiplications and no other operation", muls),
                   UVM_NONE)
   endfunction : report_phase

endclass : chequeo
