// Una operacion dirigida, con los tres campos afuera y el resultado de vuelta.
// Es el maxmult_sequence de la seccion, parametrizado: hace falta para el tercer
// paso de la sequence virtual, donde el operando de una VTALU sale del
// resultado de la otra.
class un_op_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(un_op_sequence)

   byte unsigned     A, B;
   operation_t       op;
   shortint unsigned result;  // lo escribe el driver adentro del item

   function new(string name = "un_op_sequence");
      super.new(name);
   endfunction : new

   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.A  = A;
      command.B  = B;
      command.op = op;
      finish_item(command);
      // finish_item() vuelve despues del item_done() del driver, asi que el
      // result ya esta escrito. Es el camino de vuelta de la unidad 23.
      result = command.result;
   endtask : body

endclass : un_op_sequence
