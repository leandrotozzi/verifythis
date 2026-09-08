class fifo_env extends uvm_env;
   `uvm_component_utils(fifo_env)

   fifo_agent        agent_h, stim_agent_h;
   fifo_agent_config agent_cfg_h, stim_cfg_h;

   fifo_scoreboard   scoreboard_h, stim_scoreboard_h;
   fifo_coverage     coverage_h, stim_coverage_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      fifo_env_config cfg;

      if (!uvm_config_db#(fifo_env_config)::get(this, "", "config", cfg))
         `uvm_fatal("ENV", "Failed to get env config")

      agent_cfg_h = new(.bfm(cfg.bfm), .is_active(UVM_ACTIVE));
      stim_cfg_h  = new(.bfm(cfg.stim_bfm), .is_active(UVM_PASSIVE));

      uvm_config_db#(fifo_agent_config)::set(this, "agent_h*", "config", agent_cfg_h);
      uvm_config_db#(fifo_agent_config)::set(this, "stim_agent_h*", "config", stim_cfg_h);

      agent_h      = fifo_agent::type_id::create("agent_h", this);
      stim_agent_h = fifo_agent::type_id::create("stim_agent_h", this);

      // Un scoreboard por FIFO: son dos DUT con dos estados distintos.
      scoreboard_h      = fifo_scoreboard::type_id::create("scoreboard_h", this);
      stim_scoreboard_h = fifo_scoreboard::type_id::create("stim_scoreboard_h", this);
      coverage_h        = fifo_coverage::type_id::create("coverage_h", this);
      stim_coverage_h   = fifo_coverage::type_id::create("stim_coverage_h", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      agent_h.ap_ciclo.connect(scoreboard_h.imp_ciclo);
      agent_h.ap_dato.connect(scoreboard_h.imp_dato);
      agent_h.ap_ciclo.connect(coverage_h.analysis_export);

      stim_agent_h.ap_ciclo.connect(stim_scoreboard_h.imp_ciclo);
      stim_agent_h.ap_dato.connect(stim_scoreboard_h.imp_dato);
      stim_agent_h.ap_ciclo.connect(stim_coverage_h.analysis_export);
   endfunction : connect_phase

endclass : fifo_env
