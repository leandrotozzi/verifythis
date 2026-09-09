// ONLY for the trap slide: identical to default_seq_test minus the line
// set_automatic_phase_objection(1). It runs, does not report a single error, exits
// with code 0 -- and ends at t=0 without having sent one stimulus.
class no_objection_test extends base_test;
   `uvm_component_utils(no_objection_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      full_sequence full_seq;
      super.build_phase(phase);

      full_seq = full_sequence::type_id::create("full_seq");
      full_seq.count = 200;
      // Missing on purpose: full_seq.set_automatic_phase_objection(1);
      uvm_config_db#(uvm_sequence_base)::set(
          this, "env_h.clase_agent_h.sequencer_h.main_phase", "default_sequence",
          full_seq);
   endfunction : build_phase

endclass : no_objection_test
