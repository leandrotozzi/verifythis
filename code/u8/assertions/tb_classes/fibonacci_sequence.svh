// Fibonacci with the VTALU adder. Every addition needs the RESULT of the previous
// one: it is the case that forces reading the item back, and that with the tester
// of the Transactions section could not be written without giving the monitor a handle.
class fibonacci_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(fibonacci_sequence)

   function new(string name = "fibonacci_sequence");
      super.new(name);
   endfunction : new

   task body();
      byte unsigned n_menos_2 = 0;
      byte unsigned n_menos_1 = 1;
      command_transaction command;

      command = command_transaction::type_id::create("command");
      start_item(command);
      command.op = rst_op;
      finish_item(command);

      `uvm_info("FIBONACCI", "Fib(01) = 000", UVM_MEDIUM)
      `uvm_info("FIBONACCI", "Fib(02) = 001", UVM_MEDIUM)

      // Up to 14 and no further: Fib(14) = 233 and Fib(15) = 377, which does not
      // fit in the 8 bits of A and B.
      for (int ff = 3; ff <= 14; ff++) begin : fib_loop
         command = command_transaction::type_id::create("command");
         start_item(command);
         command.A  = n_menos_2;
         command.B  = n_menos_1;
         command.op = add_op;
         finish_item(command);        // comes back when the driver did item_done()

         n_menos_2 = n_menos_1;
         n_menos_1 = command.result;  // the driver wrote it inside the item
         `uvm_info("FIBONACCI", $sformatf("Fib(%02d) = %03d", ff, n_menos_1),
                   UVM_MEDIUM)
      end : fib_loop
   endtask : body

endclass : fibonacci_sequence
