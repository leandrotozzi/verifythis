// The exercise, already written. There is no need to touch it.
//
// It starts the stimulus in three stretches, which is the shape of the sequences section:
//
//   1. reset_sequence           the DUT starts with reset_n at 0
//   2. random_sequence          the "cheap bulk": COUNT random operations
//   3. cierre_sequence          yours: the directed case that fills the bin
//
// +SIN_CIERRE skips stretch 3. It is how run.sh measures the coverage BEFORE your
// directed case, so it can compare it with the one after.
class cierre_test extends base_test;
   `uvm_component_utils(cierre_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      reset_sequence  reset_seq;
      random_sequence random_seq;
      cierre_sequence cierre_seq;
      int             count = 60;

      void'($value$plusargs("COUNT=%d", count));

      reset_seq  = reset_sequence::type_id::create("reset_seq");
      random_seq = random_sequence::type_id::create("random_seq");
      random_seq.count = count;

      phase.raise_objection(this);
      reset_seq.start(sequencer_h);
      random_seq.start(sequencer_h);

      if (!$test$plusargs("SIN_CIERRE")) begin
         cierre_seq = cierre_sequence::type_id::create("cierre_seq");
         cierre_seq.start(sequencer_h);
      end
      phase.drop_objection(this);
   endtask : run_phase

endclass : cierre_test
