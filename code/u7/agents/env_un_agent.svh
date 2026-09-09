// ILLUSTRATION -- not compiled. The env of a SINGLE VTALU, to compare against
// the env.svh of the Transactions section.
// cb: class-and-build
class env extends uvm_env;
   `uvm_component_utils(env)

   vtalu_agent        agent_h;
   vtalu_agent_config agent_cfg_h;

   scoreboard scoreboard_h;
   coverage   coverage_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      virtual vtalu_bfm bfm;

      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("ENV", "Failed to get BFM")

      agent_cfg_h = new(.bfm(bfm), .is_active(UVM_ACTIVE));
      uvm_config_db#(vtalu_agent_config)::set(this, "agent_h*", "config", agent_cfg_h);

      agent_h      = vtalu_agent::type_id::create("agent_h", this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
      coverage_h   = coverage::type_id::create("coverage_h", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      agent_h.command_ap.connect(scoreboard_h.cmd_f.analysis_export);
      agent_h.command_ap.connect(coverage_h.analysis_export);
      agent_h.result_ap.connect(scoreboard_h.analysis_export);
   endfunction : connect_phase
// cb: end

endclass : env
