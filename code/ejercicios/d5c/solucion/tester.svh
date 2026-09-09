// Solution to the day 5 exercise -- close a bin.
//
// The two lines that matter:
//
//   command.data.constraint_mode(0)
//       turns the `dist` constraint off ONLY for this object. For a directed
//       case it makes no sense anyway -- we do not want a split, we want a
//       value -- and it is also the workaround for the Verilator hole: with the
//       dist on, `with {A == 8'hFF}` solves one time in four, and the rest
//       return 0. An intermittent directed case.
//
//   if (!command.randomize() with {...}) `uvm_fatal
//       with if, not with assert(): assert is a simulation directive and a
//       simulator with asserts turned off does not execute the argument.
class tester extends uvm_component;
   `uvm_component_utils(tester)

   uvm_put_port #(command_transaction) command_port;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      command_port = new("command_port", this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      command_transaction command;
      int                 count = 60;

      void'($value$plusargs("COUNT=%d", count));

      phase.raise_objection(this);

      command = command_transaction::type_id::create("command");
      command.op = rst_op;
      command_port.put(command);

      repeat (count) begin : random_loop
         command = command_transaction::type_id::create("command");
         if (!command.randomize()) `uvm_fatal("TESTER", "randomize() failed")
         command_port.put(command);
      end : random_loop

      if (!$test$plusargs("SIN_CIERRE")) begin : el_cierre
         command = command_transaction::type_id::create("command");

         command.data.constraint_mode(0);
         if (!command.randomize() with {A == 8'hFF; B == 8'hFF; op == mul_op;})
            `uvm_fatal("CIERRE", "randomize() with failed")

         command_port.put(command);
         `uvm_info("CIERRE", $sformatf("A=%2h B=%2h op=%s",
                   command.A, command.B, command.op.name()), UVM_NONE)
      end : el_cierre

      #500;
      phase.drop_objection(this);
   endtask : run_phase
endclass : tester
