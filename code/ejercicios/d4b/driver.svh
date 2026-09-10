// TODO(exercise d4b): the test ends with the bus half empty. Fix it HERE.
//
// The tester finishes putting its thousand commands at t = 0, waits its #500
// and drops the objection. By then the driver has sent thirteen: the rest are
// still in the FIFO when the simulation ends, and UVM says PASS.
//
// The #500 of base_tester.svh is a patch, and it is not the fix: with the
// unbounded FIFO the tester no longer knows anything about the bus, so it cannot
// know when the bus is done. The one who does know is this class.
//
// What is asked for: while there is a command in flight, this component holds an
// objection of its own. The phase ends when nobody is holding one -- which is
// when the last command really went out.
//
//   uvm_phase is the argument of run_phase: phase.raise_objection(this) and
//   phase.drop_objection(this), the same pair as the day 3 test.
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
         bfm.send_op(command.A, command.B, command.op);
      end : command_loop
   endtask : run_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : driver
