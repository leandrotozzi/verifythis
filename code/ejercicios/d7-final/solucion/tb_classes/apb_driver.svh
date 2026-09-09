class apb_driver extends uvm_driver #(apb_transaction);
   `uvm_component_utils(apb_driver)

   virtual apb_if bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      apb_agent_config cfg;
      if (!uvm_config_db#(apb_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("DRIVER", "Failed to get agent config")
      bfm = cfg.bfm;
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      apb_transaction t;
      // The reset goes here and not in a sequence: in this DUT it happens once,
      // before everything. The day a reset is needed in the middle of a test,
      // it becomes one more item -- like the VTALU's rst_op.
      bfm.reset();
      forever begin : loop
         seq_item_port.get_next_item(t);
         bfm.transfer(t.write, t.addr, t.wdata, t.rdata, t.slverr);
         seq_item_port.item_done();
      end : loop
   endtask : run_phase

endclass : apb_driver
