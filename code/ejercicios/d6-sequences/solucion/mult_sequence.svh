class mult_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(mult_sequence)

   int unsigned      count = 20;   // cuantas multiplicaciones mandar
   int unsigned      items = 0;    // cuantas mando de verdad
   shortint unsigned max = 0;      // el resultado mas grande que vio

   function new(string name = "mult_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;

      // Primero el reset. Sin el, el DUT no levanta done, el driver se queda en
      // su while y esta sequence se cuelga en el primer finish_item().
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.op = rst_op;
      finish_item(command);

      repeat (count) begin : mult_loop
         command = command_transaction::type_id::create("command");
         start_item(command);
         // Randomizacion tardia. op no tiene dist, asi que el with {} anda; si
         // restringieras A o B habria que apagar antes la constraint data con
         // command.data.constraint_mode(0).
         if (!command.randomize() with {op == mul_op;})
            `uvm_fatal("MULT SEQ", "randomize() fallo")
         finish_item(command);

         // finish_item() volvio: el driver ya escribio el resultado adentro.
         items++;
         if (command.result > max) max = command.result;
      end : mult_loop

      `uvm_info("MULT SEQ", $sformatf("items=%0d max=%0d", items, max), UVM_NONE)
   endtask : body

endclass : mult_sequence
