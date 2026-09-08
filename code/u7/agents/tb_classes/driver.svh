class driver extends uvm_driver #(command_transaction);
   `uvm_component_utils(driver)

   virtual vtalu_bfm bfm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      vtalu_agent_config cfg;
      // La BFM no se pide suelta: se pide el config del agent, y de ahi sale.
      if (!uvm_config_db#(vtalu_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("DRIVER", "Failed to get agent config")
      bfm = cfg.bfm;
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      command_transaction command;
      forever begin : command_loop
         seq_item_port.get_next_item(command);
         bfm.send_op(command.A, command.B, command.op);
         seq_item_port.item_done();
      end : command_loop
   endtask : run_phase

endclass : driver
