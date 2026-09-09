// Stage 1: the passive agent watching the usual module's bus. There is no
// sequence, there is no driver doing anything: all there is to do is WATCH.
class monitor_test extends base_test;
   `uvm_component_utils(monitor_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      // The stimulus is not ours and does not say when it ends: it is eight
      // transfers of four or five cycles, and this is one hundred and fifty.
      #3000;
      phase.drop_objection(this);
   endtask : run_phase

endclass : monitor_test
