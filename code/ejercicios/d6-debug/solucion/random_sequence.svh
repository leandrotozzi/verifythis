class random_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(random_sequence)

   // The length is a field, not a new class. Since the sequence is an object and
   // not a component, whoever starts it can change it before start().
   int unsigned count = 1000;

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;

      repeat (count) begin : random_loop
         // Through the factory, same as in the Transactions section: that is what lets
         // add_test change the TYPE without touching a line of this sequence.
         command = command_transaction::type_id::create("command");

         start_item(command);

         // Late randomization: the values are picked AFTER getting the
         // sequencer's turn, not when the object was created.
         if (!command.randomize())
            `uvm_fatal("RANDOM SEQUENCE", "randomize() failed")

         finish_item(command);
      end : random_loop
   endtask : body

endclass : random_sequence
