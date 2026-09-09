// Same env, same agent, same driver, same BFM. Only the sequence changes.
class fibonacci_test extends base_test;
   `uvm_component_utils(fibonacci_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      fibonacci_sequence fibonacci_seq;
      fibonacci_seq = fibonacci_sequence::type_id::create("fibonacci_seq");

      phase.raise_objection(this);
      fibonacci_seq.start(sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase

endclass : fibonacci_test
