// TODO(exercise d6-debug) -- BUG 3 of 3, and the most expensive one.
//
// Symptom: none either. add_test runs, closes green, and the coverage even goes
// up. What it does NOT do is what its name says: add_test asks the factory to
// hand back an add_transaction --every operation an add-- and this sequence
// keeps sending random operations.
//
// It is the trap of the transactions section, and it is dumb: there is no error,
// no warning, and the topology does not show it either, because what got built
// wrong is an object and not a component.
class random_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(random_sequence)

   int unsigned count = 1000;

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;

      repeat (count) begin : random_loop
         command = new("command");

         start_item(command);

         if (!command.randomize())
            `uvm_fatal("RANDOM SEQUENCE", "randomize() failed")

         finish_item(command);
      end : random_loop
   endtask : body

endclass : random_sequence
