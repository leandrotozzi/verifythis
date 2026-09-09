class fifo_driver extends uvm_driver #(fifo_transaction);
   `uvm_component_utils(fifo_driver)

   virtual fifo_if bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      fifo_agent_config cfg;
      if (!uvm_config_db#(fifo_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("DRIVER", "Failed to get agent config")
      bfm = cfg.bfm;
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      fifo_transaction t;
      bfm.reset();
      forever begin : loop
         seq_item_port.get_next_item(t);
         // The driver does NOT look at the flags: it sends what the sequence asked for,
         // even when the FIFO is full. A driver that censors itself covers up
         // exactly the case that has to be verified.
         bfm.ciclo(t.wr_en, t.wr_data, t.rd_en);
         seq_item_port.item_done();
      end : loop
   endtask : run_phase

endclass : fifo_driver
