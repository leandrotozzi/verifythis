// Stage 1: the passive agent watching the usual module's FIFO. There is no
// sequence: all there is to do is WATCH.
class monitor_test extends base_test;
   `uvm_component_utils(monitor_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      // The stimulus is not ours and does not say when it ends: it is twelve cycles
      // of two edges each, and this is fifty.
      #1200;
      phase.drop_objection(this);
   endtask : run_phase

endclass : monitor_test
