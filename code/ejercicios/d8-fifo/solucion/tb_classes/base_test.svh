// Abstract: nobody runs +UVM_TESTNAME=base_test. It builds the structure and nothing
// else -- the stimulus is each test's job.
virtual class base_test extends uvm_test;
   `uvm_component_abstract_utils(base_test)

   fifo_env       env_h;
   fifo_sequencer sequencer_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      virtual fifo_if bfm, stim_bfm;
      fifo_env_config cfg;

      if (!uvm_config_db#(virtual fifo_if)::get(this, "", "bfm", bfm))
         `uvm_fatal("BASE TEST", "Failed to get bfm")
      if (!uvm_config_db#(virtual fifo_if)::get(this, "", "stim_bfm", stim_bfm))
         `uvm_fatal("BASE TEST", "Failed to get stim_bfm")

      cfg = new(.bfm(bfm), .stim_bfm(stim_bfm));
      uvm_config_db#(fifo_env_config)::set(this, "env_h*", "config", cfg);

      env_h = fifo_env::type_id::create("env_h", this);
   endfunction : build_phase

   function void end_of_elaboration_phase(uvm_phase phase);
      sequencer_h = env_h.agent_h.sequencer_h;
      if ($test$plusargs("TOPOLOGY")) uvm_root::get().print_topology();
   endfunction : end_of_elaboration_phase

endclass : base_test
