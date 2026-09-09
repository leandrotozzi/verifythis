class vtalu_agent extends uvm_agent;
   `uvm_component_utils(vtalu_agent)

   vtalu_agent_config cfg;

   sequencer       sequencer_h;
   driver          driver_h;
   command_monitor command_monitor_h;
   result_monitor  result_monitor_h;

   uvm_analysis_port #(command_transaction) command_ap;
   uvm_analysis_port #(result_transaction)  result_ap;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(vtalu_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("AGENT", "Failed to get agent config")
      is_active = cfg.get_is_active();

      // TODO(exercise 6): these two lines have to run ONLY if the agent is
      // active. Today they always run, so is_active is good for nothing.
      // Look at get_is_active().
      sequencer_h = sequencer::type_id::create("sequencer_h", this);
      driver_h    = driver::type_id::create("driver_h", this);

      // The monitors and the two analysis ports, on the other hand, go ALWAYS.
      command_monitor_h = command_monitor::type_id::create("command_monitor_h", this);
      result_monitor_h  = result_monitor::type_id::create("result_monitor_h", this);

      command_ap = new("command_ap", this);
      result_ap  = new("result_ap", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      // TODO(exercise 6): this connection is the active agent's only too. A
      // passive agent has no driver and no sequencer, so this line goes looking
      // for a port on a null.
      driver_h.seq_item_port.connect(sequencer_h.seq_item_export);

      command_monitor_h.ap.connect(command_ap);
      result_monitor_h.ap.connect(result_ap);
   endfunction : connect_phase

endclass : vtalu_agent
