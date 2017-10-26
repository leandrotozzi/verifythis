class tinyalu_driver_c extends uvm_component;
   `uvm_component_utils(tinyalu_driver_c)

   virtual tinyalu_bfm bfm;

   uvm_get_port #(command_s) command_port;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
   
   function void build_phase(uvm_phase phase);
      bfm = tinyalu_pkg::bfm_g;
      command_port = new("command_port",this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      command_s    command;
      shortint     result;
      
      forever begin : command_loop
         command_port.get(command);
         bfm.send_op(command.A, command.B, command.op, result);
      end : command_loop
   endtask : run_phase
   
   
endclass : tinyalu_driver_c

