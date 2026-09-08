class env extends uvm_env;
   `uvm_component_utils(env);

   vtalu_agent        clase_agent_h, modulo_agent_h;
   vtalu_agent_config clase_cfg_h, modulo_cfg_h;

   scoreboard clase_scoreboard_h, modulo_scoreboard_h;
   coverage   clase_coverage_h, modulo_coverage_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      env_config env_config_h;

      if (!uvm_config_db#(env_config)::get(this, "", "config", env_config_h))
         `uvm_fatal("ENV", "Failed to get env config")

      // Un config por agent: distinta BFM y distinto is_active.
      clase_cfg_h  = new(.bfm(env_config_h.clase_bfm),  .is_active(UVM_ACTIVE));
      modulo_cfg_h = new(.bfm(env_config_h.modulo_bfm), .is_active(UVM_PASSIVE));

      // El ambito es la RUTA del componente que va a leer, no una etiqueta. El
      // asterisco es el que hace que el driver y los monitores de adentro
      // encuentren el mismo config. Con "*" en las dos lineas, la segunda pisa
      // a la primera y los dos agents arrancan iguales.
      uvm_config_db#(vtalu_agent_config)::set(this, "clase_agent_h*", "config", clase_cfg_h);
      uvm_config_db#(vtalu_agent_config)::set(this, "modulo_agent_h*", "config", modulo_cfg_h);

      clase_agent_h  = vtalu_agent::type_id::create("clase_agent_h", this);
      modulo_agent_h = vtalu_agent::type_id::create("modulo_agent_h", this);

      // El analisis vive aca, no adentro del agent: un agent pasivo no deberia
      // arrastrar un scoreboard. Y dos coberturas separadas es justamente lo
      // que responde cual de los dos estimulos cubre mas.
      clase_scoreboard_h  = scoreboard::type_id::create("clase_scoreboard_h", this);
      modulo_scoreboard_h = scoreboard::type_id::create("modulo_scoreboard_h", this);
      clase_coverage_h    = coverage::type_id::create("clase_coverage_h", this);
      modulo_coverage_h   = coverage::type_id::create("modulo_coverage_h", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      // El env nunca nombra un monitor: habla con los analysis ports del agent.
      clase_agent_h.command_ap.connect(clase_scoreboard_h.cmd_f.analysis_export);
      clase_agent_h.command_ap.connect(clase_coverage_h.analysis_export);
      clase_agent_h.result_ap.connect(clase_scoreboard_h.analysis_export);

      modulo_agent_h.command_ap.connect(modulo_scoreboard_h.cmd_f.analysis_export);
      modulo_agent_h.command_ap.connect(modulo_coverage_h.analysis_export);
      modulo_agent_h.result_ap.connect(modulo_scoreboard_h.analysis_export);
   endfunction : connect_phase

endclass : env
