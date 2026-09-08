class apb_env extends uvm_env;
   `uvm_component_utils(apb_env)

   apb_agent        agent_h, stim_agent_h;
   apb_agent_config agent_cfg_h, stim_cfg_h;

   apb_scoreboard   scoreboard_h, stim_scoreboard_h;
   apb_coverage     coverage_h, stim_coverage_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      apb_env_config cfg;

      if (!uvm_config_db#(apb_env_config)::get(this, "", "config", cfg))
         `uvm_fatal("ENV", "Failed to get env config")

      // El del testbench maneja; el del modulo de siempre solo mira.
      agent_cfg_h = new(.bfm(cfg.bfm), .is_active(UVM_ACTIVE));
      stim_cfg_h  = new(.bfm(cfg.stim_bfm), .is_active(UVM_PASSIVE));

      uvm_config_db#(apb_agent_config)::set(this, "agent_h*", "config", agent_cfg_h);
      uvm_config_db#(apb_agent_config)::set(this, "stim_agent_h*", "config", stim_cfg_h);

      agent_h      = apb_agent::type_id::create("agent_h", this);
      stim_agent_h = apb_agent::type_id::create("stim_agent_h", this);

      // Un scoreboard y una cobertura por bus: son dos DUT distintos, con dos
      // estados distintos. Un solo scoreboard mezclando los dos no cerraria.
      scoreboard_h      = apb_scoreboard::type_id::create("scoreboard_h", this);
      stim_scoreboard_h = apb_scoreboard::type_id::create("stim_scoreboard_h", this);
      coverage_h        = apb_coverage::type_id::create("coverage_h", this);
      stim_coverage_h   = apb_coverage::type_id::create("stim_coverage_h", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      agent_h.ap.connect(scoreboard_h.analysis_export);
      agent_h.ap.connect(coverage_h.analysis_export);

      stim_agent_h.ap.connect(stim_scoreboard_h.analysis_export);
      stim_agent_h.ap.connect(stim_coverage_h.analysis_export);
   endfunction : connect_phase

endclass : apb_env
