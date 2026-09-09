// The test does not change shape: it creates a sequence and starts it. The only
// difference is WHAT it starts it on -- the virtual sequencer, not the agent's.
class virtual_test extends base_test;
   `uvm_component_utils(virtual_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      coordinada_sequence seq;
      seq = coordinada_sequence::type_id::create("seq");

      phase.raise_objection(this);
      seq.start(env_h.virtual_sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase

endclass : virtual_test
