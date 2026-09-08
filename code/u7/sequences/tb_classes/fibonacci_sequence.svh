// Fibonacci con el sumador del VTALU. Cada suma necesita el RESULTADO de la
// anterior: es el caso que obliga a leer el item de vuelta, y que con el tester
// de la seccion Transactions no se podia escribir sin darle un handle al monitor.
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

      // Hasta 14 y no mas: Fib(14) = 233 y Fib(15) = 377, que no entra en los
      // 8 bits de A y de B.
      for (int ff = 3; ff <= 14; ff++) begin : fib_loop
         command = command_transaction::type_id::create("command");
         start_item(command);
         command.A  = n_menos_2;
         command.B  = n_menos_1;
         command.op = add_op;
         finish_item(command);        // vuelve cuando el driver hizo item_done()

         n_menos_2 = n_menos_1;
         n_menos_1 = command.result;  // el driver lo escribio adentro del item
         `uvm_info("FIBONACCI", $sformatf("Fib(%02d) = %03d", ff, n_menos_1),
                   UVM_MEDIUM)
      end : fib_loop
   endtask : body

endclass : fibonacci_sequence
