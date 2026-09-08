class maxmult_sequence extends uvm_sequence #(command_transaction);
   `uvm_object_utils(maxmult_sequence)

   function new(string name = "maxmult_sequence");
      super.new(name);
   endfunction : new

   // Dirigida: el desborde del multiplicador, que 1000 operaciones al azar
   // podrian no tocar nunca. No se randomiza, asi que ninguna constraint corre
   // -- ni siquiera la de add_transaction cuando el add_test hace el override.
   task body();
      command_transaction command;
      command = command_transaction::type_id::create("command");
      start_item(command);
      command.op = mul_op;
      command.A  = 8'hFF;
      command.B  = 8'hFF;
      finish_item(command);
      // El resultado ya esta adentro del item: lo escribio el driver antes de
      // item_done(), y finish_item() volvio despues de eso.
      `uvm_info("MAXMULT", $sformatf("FF x FF = %4h", command.result), UVM_MEDIUM)
   endtask : body

endclass : maxmult_sequence
