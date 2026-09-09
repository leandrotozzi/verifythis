// Day 6 exercise -- close a bin.
//
// The missing bin is the one in the coverage plan of the Functional coverage section: "both legs
// at FF, multiplying". With 60 random operations it does not fill, and the report
// run.sh prints shows you that.
//
// What is asked: send ONE transaction with A = 8'hFF, B = 8'hFF and op = mul_op,
// asked for with randomize() with {} -- not by assigning the fields by hand. The directed
// case is asked for at the point of use; that is the tool from the Transactions section.
//
// Two warnings that are in the slides and that you are going to need:
//
//   1. command_transaction has a `dist` on A and on B. Verilator solves
//      the dist by PICKING A VALUE first and then checking the rest: if the
//      draw does not satisfy your with, randomize() returns 0 instead of retrying.
//      The workaround is in the Constrained random section and it is one line.
//   2. randomize() gets checked with if, never with assert().
class cierre_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(cierre_sequence)

   function new(string name = "cierre_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");

      start_item(command);

      // <<< HERE >>>  randomize() with { ... }, and whatever is needed before it.

      finish_item(command);

      `uvm_info("CIERRE", $sformatf("A=%2h B=%2h op=%s result=%4h",
                command.A, command.B, command.op.name(), command.result), UVM_NONE)
   endtask : body

endclass : cierre_sequence
