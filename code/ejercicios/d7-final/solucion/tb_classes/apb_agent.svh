class apb_agent extends uvm_agent;
   `uvm_component_utils(apb_agent)

   apb_agent_config cfg;

   apb_sequencer sequencer_h;
   apb_driver    driver_h;
   apb_monitor   monitor_h;

   uvm_analysis_port #(apb_transaction) ap;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(apb_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("AGENT", "Failed to get agent config")
      is_active = cfg.get_is_active();

      if (get_is_active() == UVM_ACTIVE) begin : estimulo
         sequencer_h = apb_sequencer::type_id::create("sequencer_h", this);
         driver_h    = apb_driver::type_id::create("driver_h", this);
      end : estimulo

      // El monitor existe siempre: es lo unico que un agent pasivo hace.
      monitor_h = apb_monitor::type_id::create("monitor_h", this);
      ap = new("ap", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      if (get_is_active() == UVM_ACTIVE)
         driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
      monitor_h.ap.connect(ap);
   endfunction : connect_phase

endclass : apb_agent
