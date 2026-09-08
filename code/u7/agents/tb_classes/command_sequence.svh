// El run_phase del tester de u6/transactions, convertido en el body() de una sequence.
// Mismo estimulo, misma cantidad, mismos casos dirigidos.
//
// Lo que cambio: ya no es un uvm_component, no esta en el arbol, no se conecta
// a nada y no levanta el objection -- eso lo hace el test que la arranca.
class command_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(command_sequence)

   function new(string name = "command_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;

      // Todas las transactions salen de la factory, tambien las dirigidas:
      // un new() se saltearia el set_type_override de add_test.
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.op = rst_op;
      finish_item(command);

      repeat (1000) begin : random_loop
         command = command_transaction::type_id::create("command");
         start_item(command);
         // El randomize() va ENTRE start_item y finish_item: asi las
         // constraints se resuelven cuando el item se va a entregar, y no
         // antes. Hoy da igual; el dia que una constraint dependa del estado
         // del DUT, no.
         if (!command.randomize()) `uvm_fatal("COMMAND SEQ", "randomize() fallo")
         finish_item(command);
      end : random_loop

      // Dirigida: el desborde del multiplicador, que 1000 operaciones al azar
      // podrian no tocar nunca. Sale de la factory igual que las otras, pero
      // como no se randomiza, la constraint de add_transaction no corre.
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.op = mul_op;
      command.A  = 8'hFF;
      command.B  = 8'hFF;
      finish_item(command);
   endtask : body

endclass : command_sequence
