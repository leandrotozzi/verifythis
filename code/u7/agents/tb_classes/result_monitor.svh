class result_monitor extends uvm_monitor;
   `uvm_component_utils(result_monitor);

   virtual vtalu_bfm bfm;
   uvm_analysis_port #(result_transaction) ap;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      vtalu_agent_config cfg;
      if (!uvm_config_db#(vtalu_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("RESULT MONITOR", "Failed to get agent config")
      bfm = cfg.bfm;
      bfm.result_monitor_h = this;
      ap = new("ap", this);
   endfunction : build_phase

   function void write_to_monitor(shortint r, bit o);
      result_transaction result_t;
      result_t = result_transaction::type_id::create("result_t");
      result_t.result = r;
      result_t.ovf    = o;
      ap.write(result_t);
   endfunction : write_to_monitor

endclass : result_monitor
