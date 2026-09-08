class tester extends uvm_component;
   `uvm_component_utils(tester)

   uvm_put_port #(command_transaction) command_port;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      command_port = new("command_port", this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      command_transaction command;

      phase.raise_objection(this);

      // TODAS las transactions salen de la factory, tambien las dirigidas.
      // Un new() aca compilaria y andaria igual, pero se saltearia el
      // set_type_override de add_test: la factory no se entera de lo que
      // construis a mano. Ver la slide "el new() que se come el override".
      command = command_transaction::type_id::create("command");
      command.op = rst_op;
      command_port.put(command);

      repeat (1000) begin : random_loop
         command = command_transaction::type_id::create("command");
         // randomize() devuelve 0 si las constraints no tienen solucion, y no
         // aborta nada. Un assert() pelado deja pasar en silencio una
         // transaction sin randomizar: el TB sigue, mandando basura.
         if (!command.randomize()) `uvm_fatal("TESTER", "randomize() fallo")
         command_port.put(command);
      end : random_loop

      // Dirigida: el caso de desborde del multiplicador, que 1000 operaciones
      // al azar podrian no tocar nunca. Sale de la factory igual que las otras,
      // pero como no se randomiza, la constraint de add_transaction no corre:
      // la factory elige el TIPO, las constraints solo actuan en randomize().
      command = command_transaction::type_id::create("command");
      command.op = mul_op;
      command.A = 8'hFF;
      command.B = 8'hFF;
      command_port.put(command);

      #500;
      phase.drop_objection(this);
   endtask : run_phase
endclass : tester
