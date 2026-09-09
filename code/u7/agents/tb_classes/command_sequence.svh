// The run_phase of the u6/transactions tester, turned into the body() of a sequence.
// Same stimulus, same count, same directed cases.
//
// What changed: it is no longer a uvm_component, it is not in the tree, it
// connects to nothing and it does not raise the objection -- the test that starts it does.
class command_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(command_sequence)

   function new(string name = "command_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;

      // All transactions come out of the factory, the directed ones too:
      // a new() would skip add_test's set_type_override.
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.op = rst_op;
      finish_item(command);

      repeat (1000) begin : random_loop
         command = command_transaction::type_id::create("command");
         start_item(command);
         // The randomize() goes BETWEEN start_item and finish_item: that way the
         // constraints are solved when the item is about to be handed over, and
         // not before. Today it makes no difference; the day a constraint
         // depends on the DUT state, it will.
         if (!command.randomize()) `uvm_fatal("COMMAND SEQ", "randomize() failed")
         finish_item(command);
      end : random_loop

      // Directed: the multiplier overflow, which 1000 random operations might
      // never touch. It comes out of the factory like the others, but since it
      // is not randomized, add_transaction's constraint does not run.
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.op = mul_op;
      command.A  = 8'hFF;
      command.B  = 8'hFF;
      finish_item(command);
   endtask : body

endclass : command_sequence
