class apb_monitor extends uvm_monitor;
   `uvm_component_utils(apb_monitor)

   virtual apb_if bfm;
   uvm_analysis_port #(apb_transaction) ap;

   int unsigned vistas;  // cuantas transferencias paso: lo mira monitor_test

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      apb_agent_config cfg;
      if (!uvm_config_db#(apb_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("MONITOR", "Failed to get agent config")
      bfm = cfg.bfm;
      bfm.monitor_h = this;
      ap = new("ap", this);
   endfunction : build_phase

   // The interface calls it on the edge where the transfer ends.
   function void write_to_monitor(bit write, bit [7:0] addr, bit [31:0] wdata,
                                  bit [31:0] rdata, bit slverr);
      apb_transaction t;
      t = apb_transaction::type_id::create("t");
      t.write = write;
      t.addr = addr;
      t.wdata = wdata;
      t.rdata = rdata;
      t.slverr = slverr;
      vistas++;
      `uvm_info("MONITOR", t.convert2string(), UVM_MEDIUM)
      ap.write(t);
   endfunction : write_to_monitor

endclass : apb_monitor
