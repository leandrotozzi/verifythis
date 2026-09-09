// TODO(exercise d6-debug) -- BUG 2 of 3.
//
// Symptom: none. default_seq_test ends at t=0, reports 0 UVM_ERROR, exits with
// code 0 and UVM says the testbench passed. It did not send a single stimulus.
//
// A sequence started by config_db does not run inside a run_phase that anybody
// wrote, so nobody raises the objection for it. There is one line for that, and
// the trap slide of the sequences section names it.
class default_seq_test extends base_test;
   `uvm_component_utils(default_seq_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      full_sequence full_seq;
      super.build_phase(phase);

      full_seq = full_sequence::type_id::create("full_seq");
      full_seq.count = 200;
      uvm_config_db#(uvm_sequence_base)::set(
          this, "env_h.clase_agent_h.sequencer_h.main_phase", "default_sequence",
          full_seq);
   endfunction : build_phase

endclass : default_seq_test
