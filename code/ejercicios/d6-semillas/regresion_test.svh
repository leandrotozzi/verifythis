// The exercise, already written. There is no need to touch it.
//
// Reset and COUNT random operations, nothing else. COUNT is small on purpose: with
// 1000 the random saturates what it can reach and every seed gives the same
// number. With 25 it does not, and that is where the point of the exercise shows.
class regresion_test extends base_test;
   `uvm_component_utils(regresion_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      reset_sequence  reset_seq;
      random_sequence random_seq;
      int             count = 25;

      void'($value$plusargs("COUNT=%d", count));

      reset_seq  = reset_sequence::type_id::create("reset_seq");
      random_seq = random_sequence::type_id::create("random_seq");
      random_seq.count = count;

      phase.raise_objection(this);
      reset_seq.start(sequencer_h);
      random_seq.start(sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase

endclass : regresion_test
