// The env of the Sequences section with TWO changes, and no more:
//
//   1. the second agent is UVM_ACTIVE instead of UVM_PASSIVE;
//   2. there is a virtual_sequencer, and connect_phase hands it the handles of
//      the two real sequencers.
//
// The rest --agents, scoreboards, coverage, the config_db scope-- is
// identical. That is the point: a virtual sequence does not change the structure
// of the testbench, it only adds who coordinates it.
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

      // Both active: each with its own sequencer and driver.
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
      // The handles are passed HERE and not looked up by string: in connect_phase
      // both agents already exist, and if somebody renames a component this does
      // not compile instead of returning null at simulation time.
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
