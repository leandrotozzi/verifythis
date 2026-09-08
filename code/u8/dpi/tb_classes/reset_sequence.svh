// La sequence mas chica que existe: un solo item.
//
// Es un uvm_object, no un uvm_component: no esta en el arbol, no tiene padre,
// no tiene fases. Se crea, corre y se tira.
class reset_sequence extends uvm_sequence #(command_transaction);
   // `uvm_object_utils, NO `uvm_component_utils: el constructor tiene un solo
   // argumento y no hay parent que pasar.
   `uvm_object_utils(reset_sequence)

   function new(string name = "reset_sequence");
      super.new(name);
   endfunction : new

   // body() es una TASK, no una function: adentro se bloquea. Nadie la llama a
   // mano; la llama UVM cuando alguien arranca la sequence.
   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");
      start_item(command);    // bloquea hasta que el sequencer nos da el turno
      command.op = rst_op;    // recien ahora decidimos que mandar
      finish_item(command);   // bloquea hasta el item_done() del driver
   endtask : body

endclass : reset_sequence
