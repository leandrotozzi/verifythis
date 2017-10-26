class tester extends uvm_component;
   `uvm_component_utils (tester)

   uvm_put_port #(command_transaction) command_port;

   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      command_port = new("command_port", this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      command_transaction  command;

      phase.raise_objection(this);

      command = new("command");
      command.op = rst_op;
      command_port.put(command);

      // Este codigo tiene 2 claves:
      //    1) Usamos la factory para crear el command_transaction
      //       entonces podemos hacer un override luego
      //    2) Randomizamos los datos, por lo tanto las constraint
      //       controlan los valores que mandamos
      //    Cuando hagamos un override del command_transaction usando
      //    un add_transaction, solo tendremos sumas
      repeat (10) begin
         command = command_transaction::type_id::create("command");
         assert(command.randomize());
         command_port.put(command);
      end

      command = new("command");
      command.op = mul_op;
      command.A = 8'hFF;
      command.B = 8'hFF;
      command_port.put(command);

      #500;
      phase.drop_objection(this);
   endtask : run_phase
endclass : tester