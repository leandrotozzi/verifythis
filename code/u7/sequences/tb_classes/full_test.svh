// Same stimulus as the dual_test of the agents section, now in three sequences.
class full_test extends base_test;
   `uvm_component_utils(full_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      full_sequence full_seq;
      full_seq = full_sequence::type_id::create("full_seq");

      // THE TEST raises the objection, not the sequence: the sequence knows
      // nothing about phases, and has to be able to run inside another sequence.
      phase.raise_objection(this);
      full_seq.start(sequencer_h);   // does not return until body() finished
      phase.drop_objection(this);
   endtask : run_phase

endclass : full_test
