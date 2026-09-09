// The same stimulus as full_test, WITHOUT run_phase: the sequencer itself starts
// the sequence when the phase begins.
class default_seq_test extends base_test;
   `uvm_component_utils(default_seq_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      full_sequence full_seq;

      // super.build_phase() of base_test, which is a class of OURS: it builds the
      // env. What the course never calls is uvm_component's build_phase.
      super.build_phase(phase);

      full_seq = full_sequence::type_id::create("full_seq");
      full_seq.count = 200;

      // WITHOUT this line main_phase ends at t=0: nobody raises the objection,
      // and a phase without an objection lasts zero. The test PASSES with no stimulus.
      full_seq.set_automatic_phase_objection(1);

      // The instance name carries the "_phase" suffix: that is the phase the
      // sequencer will start it in. Notice the test no longer names the sequencer
      // as a handle: it names it as a PATH, and that is a config, not code.
      uvm_config_db#(uvm_sequence_base)::set(
          this, "env_h.clase_agent_h.sequencer_h.main_phase", "default_sequence",
          full_seq);
   endfunction : build_phase

endclass : default_seq_test
