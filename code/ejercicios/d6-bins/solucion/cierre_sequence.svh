// Solution to the day 6 exercise -- close a bin.
//
// The two lines that matter:
//
//   command.data.constraint_mode(0)
//       turns the `dist` constraint off ONLY for this object. For a directed
//       case it makes no sense anyway -- we do not want a split, we want a
//       value-- and it is also the workaround for the Verilator hole: with the dist
//       on, `with {A == 8'hFF}` solves one time in four, and the
//       rest return 0. An intermittent directed case.
//
//   if (!command.randomize() with {...}) `uvm_fatal
//       with if, not with assert(): assert is a simulation directive and a
//       simulator with asserts turned off does not execute the argument.
class cierre_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(cierre_sequence)

   function new(string name = "cierre_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");

      start_item(command);

      command.data.constraint_mode(0);
      if (!command.randomize() with {A == 8'hFF; B == 8'hFF; op == mul_op;})
         `uvm_fatal("CIERRE", "randomize() with failed")

      finish_item(command);

      `uvm_info("CIERRE", $sformatf("A=%2h B=%2h op=%s result=%4h",
                command.A, command.B, command.op.name(), command.result), UVM_NONE)
   endtask : body

endclass : cierre_sequence
