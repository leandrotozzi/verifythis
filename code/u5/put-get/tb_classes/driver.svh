class driver extends uvm_component;
   `uvm_component_utils(driver)

   virtual vtalu_bfm bfm;

   uvm_get_port #(command_s) command_port;

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("DRIVER", "Failed to get BFM")
      command_port = new("command_port", this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      command_s command;

      forever begin : command_loop
         // Bloqueante, si no hay comandos para enviar, espera
         command_port.get(command);
         bfm.send_op(command.A, command.B, command.op);
      end : command_loop
   endtask : run_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : driver
