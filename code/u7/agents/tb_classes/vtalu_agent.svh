// cb: class-and-build
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

      if (get_is_active() == UVM_ACTIVE) begin : estimulo
         sequencer_h = sequencer::type_id::create("sequencer_h", this);
         driver_h    = driver::type_id::create("driver_h", this);
      end : estimulo

      command_monitor_h = command_monitor::type_id::create("command_monitor_h", this);
      result_monitor_h  = result_monitor::type_id::create("result_monitor_h", this);

      command_ap = new("command_ap", this);
      result_ap  = new("result_ap", this);
   endfunction : build_phase
// cb: end

   function void connect_phase(uvm_phase phase);
      if (get_is_active() == UVM_ACTIVE)
         driver_h.seq_item_port.connect(sequencer_h.seq_item_export);

      command_monitor_h.ap.connect(command_ap);
      result_monitor_h.ap.connect(result_ap);
   endfunction : connect_phase

endclass : vtalu_agent
