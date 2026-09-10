// Stages 3 and 4: the random one, against the scoreboard and the coverage.
class random_test extends base_test;
   `uvm_component_utils(random_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      random_sequence seq;
      seq = random_sequence::type_id::create("seq");
      phase.raise_objection(this);
      if (!seq.randomize()) `uvm_fatal("TEST", "the sequence randomize() failed")
      seq.start(sequencer_h);
      #100;
      phase.drop_objection(this);
   endtask : run_phase

endclass : random_test
