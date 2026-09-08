virtual class base_tester extends uvm_component;
   `uvm_component_utils(base_tester)
   virtual vtalu_bfm bfm;

   uvm_put_port #(command_s) command_port;

   function void build_phase(uvm_phase phase);

      command_port = new("command_port", this);
   endfunction : build_phase

   pure virtual function operation_t get_op();

   pure virtual function byte get_data();

   task run_phase(uvm_phase phase);
      byte unsigned iA;
      byte unsigned iB;
      operation_t   op_set;
      command_s     command;

      phase.raise_objection(this);
      command.op = rst_op;
      command_port.put(command);
      // 10 y no 1000 como el resto de las secciones, A PROPOSITO: el scoreboard
      // de esta unidad falla adrede y la slide muestra su salida entera. Con
      // 1000 operaciones el transcript no entra en la pantalla y el ejemplo
      // deja de enseñar lo que vino a enseñar. Por eso u4/reporting mide 28,8 % de
      // cobertura y no 72,6 %: es el precio de que el log se pueda leer.
      repeat (10) begin : random_loop
         command.op = get_op();
         command.A = get_data();
         command.B = get_data();
         command_port.put(command);
      end : random_loop
      #500;
      phase.drop_objection(this);
   endtask : run_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : base_tester
