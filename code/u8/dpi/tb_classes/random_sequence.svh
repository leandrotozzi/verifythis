class random_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(random_sequence)

   // El largo es un campo, no una clase nueva. Como la sequence es un objeto y
   // no un componente, el que la arranca puede cambiarlo antes de start().
   int unsigned count = 1000;

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;

      repeat (count) begin : random_loop
         // Por la factory, igual que en la seccion Transactions: es lo que hace que el
         // add_test pueda cambiar el TIPO sin tocar una linea de esta sequence.
         command = command_transaction::type_id::create("command");

         start_item(command);

         // Randomizacion tardia: los valores se eligen DESPUES de tener el
         // turno del sequencer, no cuando se creo el objeto.
         if (!command.randomize())
            `uvm_fatal("RANDOM SEQUENCE", "randomize() fallo")

         finish_item(command);
      end : random_loop
   endtask : body

endclass : random_sequence
