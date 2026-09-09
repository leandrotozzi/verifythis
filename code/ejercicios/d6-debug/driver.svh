// TODO(exercise d6-debug) -- BUG 1 of 3.
//
// Symptom: full_test never ends. The log stops, the simulation keeps advancing
// time, and after the +UVM_TIMEOUT the run dies with [PH_TIMEOUT].
//
// Nothing else is wrong here: the BFM works, the sequence is fine and the
// scoreboard is fine. Read the handshake of the sequences section again --
// there are TWO calls, not one.
class driver extends uvm_driver #(command_transaction);
   `uvm_component_utils(driver)

   virtual vtalu_bfm bfm;

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
      shortint unsigned   alu_result;
      forever begin : command_loop
         seq_item_port.get_next_item(command);
         bfm.send_op(command.A, command.B, command.op, alu_result);
         command.result = alu_result;
      end : command_loop
   endtask : run_phase

endclass : driver
