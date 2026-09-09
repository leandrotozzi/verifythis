// The Agents driver with the hook added. Diff against ../agents/tb_classes:
// two lines -- `uvm_register_cb and `uvm_do_callbacks. Nothing else moves.
// cb: register-cb
class driver extends uvm_driver #(command_transaction);
   `uvm_component_utils(driver)
   // Declares "this component accepts callbacks of this type". Without it the
   // add() below still hooks up and the callback still runs, but with a CBUNREG
   // warning and without the type check: outside the contract, and nearly silent.
   `uvm_register_cb(driver, driver_callback)

   virtual vtalu_bfm bfm;
// cb: end

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      vtalu_agent_config cfg;
      if (!uvm_config_db#(vtalu_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("DRIVER", "Failed to get agent config")
      bfm = cfg.bfm;
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      command_transaction command;
      forever begin : command_loop
         seq_item_port.get_next_item(command);
         // Every callback registered on this driver, in the order they were
         // added. With none registered this is a loop over an empty queue.
         `uvm_do_callbacks(driver, driver_callback, pre_send(this, command))
         bfm.send_op(command.A, command.B, command.op);
         seq_item_port.item_done();
      end : command_loop
   endtask : run_phase

endclass : driver
