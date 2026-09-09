// Stage 2: the driver drives the FIFO, with directed stimulus.
class smoke_test extends base_test;
   `uvm_component_utils(smoke_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      smoke_sequence seq;
      seq = smoke_sequence::type_id::create("seq");
      phase.raise_objection(this);
      seq.start(sequencer_h);
      // The datum of the last cycle comes out ONE edge later: without this cushion, the
      // scoreboard is left with an unanswered read. It is the drain_time
      // of day 3, written by hand.
      #100;
      phase.drop_objection(this);
   endtask : run_phase

endclass : smoke_test
