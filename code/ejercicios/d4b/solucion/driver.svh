// The fix: the driver holds an objection while it has a command in flight.
//
// It is not "one more objection": it is the only component that knows when the
// bus is done. The tester knows when it finished PUTTING, which with an
// unbounded FIFO is t = 0 and has nothing to do with the DUT.
//
// The pair goes AFTER the get() and not around it: with it around, the driver
// would hold an objection while waiting for work that is never coming, and the
// test would never end.
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
         // Blocking: if there are no commands to send, it waits
         command_port.get(command);
         phase.raise_objection(this);
         bfm.send_op(command.A, command.B, command.op);
         phase.drop_objection(this);
      end : command_loop
   endtask : run_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : driver
