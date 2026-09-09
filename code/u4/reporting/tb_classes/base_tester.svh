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
      // 10 and not 1000 like the rest of the sections, ON PURPOSE: the scoreboard
      // in this unit fails deliberately and the slide shows its whole output. With
      // 1000 operations the transcript does not fit on the screen and the example
      // stops teaching what it came to teach. That is why u4/reporting measures 28,8 % of
      // coverage and not 72,6 %: it is the price of a readable log.
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
