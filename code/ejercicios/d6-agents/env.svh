class env extends uvm_env;
   `uvm_component_utils(env);

   vtalu_agent        clase_agent_h;
   vtalu_agent_config clase_cfg_h;
   scoreboard         clase_scoreboard_h;
   coverage           clase_coverage_h;
   // TODO(exercise 6): declare here the module's agent, its config, its
   // scoreboard and its coverage.

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      env_config env_config_h;

      if (!uvm_config_db#(env_config)::get(this, "", "config", env_config_h))
         `uvm_fatal("ENV", "Failed to get env config")

      clase_cfg_h = new(.bfm(env_config_h.clase_bfm), .is_active(UVM_ACTIVE));
      uvm_config_db#(vtalu_agent_config)::set(this, "clase_agent_h*", "config", clase_cfg_h);
      // TODO(exercise 6): build the config of the second agent -- modulo_bfm and
      // UVM_PASSIVE -- and put it in the config_db with the scope it
      // deserves. Careful: if you use "*", the second set() overwrites the first.

      clase_agent_h      = vtalu_agent::type_id::create("clase_agent_h", this);
      clase_scoreboard_h = scoreboard::type_id::create("clase_scoreboard_h", this);
      clase_coverage_h   = coverage::type_id::create("clase_coverage_h", this);
      // TODO(exercise 6): create the module's agent and its analysis pair.

   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      clase_agent_h.command_ap.connect(clase_scoreboard_h.cmd_f.analysis_export);
      clase_agent_h.command_ap.connect(clase_coverage_h.analysis_export);
      clase_agent_h.result_ap.connect(clase_scoreboard_h.analysis_export);
      // TODO(exercise 6): connect the two analysis ports of the module's agent.
      // Notice you never name a monitor: you talk to the agent's ports.

   endfunction : connect_phase

endclass : env
