class env extends uvm_env;
   `uvm_component_utils(env);

   vtalu_agent        clase_agent_h;
   vtalu_agent_config clase_cfg_h;
   scoreboard         clase_scoreboard_h;
   coverage           clase_coverage_h;
   // TODO(ejercicio 6): declara aca el agent del modulo, su config, su
   // scoreboard y su coverage.

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      env_config env_config_h;

      if (!uvm_config_db#(env_config)::get(this, "", "config", env_config_h))
         `uvm_fatal("ENV", "Failed to get env config")

      clase_cfg_h = new(.bfm(env_config_h.clase_bfm), .is_active(UVM_ACTIVE));
      uvm_config_db#(vtalu_agent_config)::set(this, "clase_agent_h*", "config", clase_cfg_h);
      // TODO(ejercicio 6): arma el config del segundo agent -- modulo_bfm y
      // UVM_PASSIVE -- y guardalo en el config_db con el ambito que le
      // corresponde. Ojo: si usas "*", el segundo set() pisa al primero.

      clase_agent_h      = vtalu_agent::type_id::create("clase_agent_h", this);
      clase_scoreboard_h = scoreboard::type_id::create("clase_scoreboard_h", this);
      clase_coverage_h   = coverage::type_id::create("clase_coverage_h", this);
      // TODO(ejercicio 6): crea el agent del modulo y su par de analisis.

   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      clase_agent_h.command_ap.connect(clase_scoreboard_h.cmd_f.analysis_export);
      clase_agent_h.command_ap.connect(clase_coverage_h.analysis_export);
      clase_agent_h.result_ap.connect(clase_scoreboard_h.analysis_export);
      // TODO(ejercicio 6): conecta los dos analysis ports del agent del modulo.
      // Fijate que nunca nombras un monitor: hablas con los puertos del agent.

   endfunction : connect_phase

endclass : env
