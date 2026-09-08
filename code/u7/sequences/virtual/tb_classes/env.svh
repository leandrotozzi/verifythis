// El env de la seccion Sequences con DOS cambios, y ninguno mas:
//
//   1. el segundo agent es UVM_ACTIVE en vez de UVM_PASSIVE;
//   2. hay un virtual_sequencer, y el connect_phase le pasa los handles de los
//      dos sequencers de verdad.
//
// El resto --agents, scoreboards, cobertura, el ambito del config_db-- es
// identico. Ese es el punto: una sequence virtual no cambia la estructura del
// testbench, solo agrega quien la coordina.
class env extends uvm_env;
   `uvm_component_utils(env);

   vtalu_agent        clase_agent_h, modulo_agent_h;
   vtalu_agent_config clase_cfg_h, modulo_cfg_h;

   scoreboard clase_scoreboard_h, modulo_scoreboard_h;
   coverage   clase_coverage_h, modulo_coverage_h;

   virtual_sequencer virtual_sequencer_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      env_config env_config_h;

      if (!uvm_config_db#(env_config)::get(this, "", "config", env_config_h))
         `uvm_fatal("ENV", "Failed to get env config")

      // Los dos activos: cada uno con su sequencer y su driver.
      clase_cfg_h  = new(.bfm(env_config_h.clase_bfm),  .is_active(UVM_ACTIVE));
      modulo_cfg_h = new(.bfm(env_config_h.modulo_bfm), .is_active(UVM_ACTIVE));

      uvm_config_db#(vtalu_agent_config)::set(this, "clase_agent_h*", "config", clase_cfg_h);
      uvm_config_db#(vtalu_agent_config)::set(this, "modulo_agent_h*", "config", modulo_cfg_h);

      clase_agent_h  = vtalu_agent::type_id::create("clase_agent_h", this);
      modulo_agent_h = vtalu_agent::type_id::create("modulo_agent_h", this);

      virtual_sequencer_h = virtual_sequencer::type_id::create("virtual_sequencer_h", this);

      clase_scoreboard_h  = scoreboard::type_id::create("clase_scoreboard_h", this);
      modulo_scoreboard_h = scoreboard::type_id::create("modulo_scoreboard_h", this);
      clase_coverage_h    = coverage::type_id::create("clase_coverage_h", this);
      modulo_coverage_h   = coverage::type_id::create("modulo_coverage_h", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      // Los handles se pasan ACA y no se buscan por string: en el connect_phase
      // los dos agents ya existen, y si alguien renombra un componente esto no
      // compila en vez de devolver null en tiempo de simulacion.
      virtual_sequencer_h.clase_sequencer_h  = clase_agent_h.sequencer_h;
      virtual_sequencer_h.modulo_sequencer_h = modulo_agent_h.sequencer_h;

      clase_agent_h.command_ap.connect(clase_scoreboard_h.cmd_f.analysis_export);
      clase_agent_h.command_ap.connect(clase_coverage_h.analysis_export);
      clase_agent_h.result_ap.connect(clase_scoreboard_h.analysis_export);

      modulo_agent_h.command_ap.connect(modulo_scoreboard_h.cmd_f.analysis_export);
      modulo_agent_h.command_ap.connect(modulo_coverage_h.analysis_export);
      modulo_agent_h.result_ap.connect(modulo_scoreboard_h.analysis_export);
   endfunction : connect_phase

endclass : env
