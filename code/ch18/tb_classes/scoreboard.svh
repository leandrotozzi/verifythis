class scoreboard extends uvm_subscriber #(shortint);
   `uvm_component_utils(scoreboard);

   virtual tinyalu_bfm bfm;
   uvm_tlm_analysis_fifo #(command_s) cmd_f;
   
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      cmd_f = new ("cmd_f", this);
   endfunction : build_phase

   function void write(shortint t);
      shortint predicted_result;
      command_s cmd; 
      cmd.A = 0;
      cmd.B = 0;
      cmd.op = no_op;
      do
        if (!cmd_f.try_get(cmd))
          $fatal(1, "Missing command in self checker");
      while ((cmd.op == no_op) || (cmd.op == rst_op));
      case (cmd.op)
        add_op: predicted_result = cmd.A + cmd.B;
        and_op: predicted_result = cmd.A & cmd.B;
        xor_op: predicted_result = cmd.A ^ cmd.B;
        mul_op: predicted_result = cmd.A * cmd.B;
      endcase // case (op_set)
      if (predicted_result != t)
       $error (
     "FAILED: A: %2h  B: %2h  op: %s actual result: %4h   expected: %4h",
         cmd.A, cmd.B, cmd.op.name(), t,  predicted_result);
   endfunction : write
   
endclass : scoreboard






