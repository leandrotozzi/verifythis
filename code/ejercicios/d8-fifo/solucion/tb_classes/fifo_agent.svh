class fifo_agent extends uvm_agent;
   `uvm_component_utils(fifo_agent)

   fifo_agent_config cfg;

   fifo_sequencer sequencer_h;
   fifo_driver    driver_h;
   fifo_monitor   monitor_h;

   uvm_analysis_port #(fifo_transaction) ap_ciclo;
   uvm_analysis_port #(dato_transaction) ap_dato;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(fifo_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("AGENT", "Failed to get agent config")
      is_active = cfg.get_is_active();

      if (get_is_active() == UVM_ACTIVE) begin : estimulo
         sequencer_h = fifo_sequencer::type_id::create("sequencer_h", this);
         driver_h    = fifo_driver::type_id::create("driver_h", this);
      end : estimulo

      monitor_h = fifo_monitor::type_id::create("monitor_h", this);
      ap_ciclo  = new("ap_ciclo", this);
      ap_dato   = new("ap_dato", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      if (get_is_active() == UVM_ACTIVE)
         driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
      monitor_h.ap_ciclo.connect(ap_ciclo);
      monitor_h.ap_dato.connect(ap_dato);
   endfunction : connect_phase

endclass : fifo_agent
