class scoreboard extends uvm_subscriber #(shortint);
   `uvm_component_utils(scoreboard);

   uvm_tlm_analysis_fifo #(command_s) cmd_f;


   function void build_phase(uvm_phase phase);
      cmd_f = new ("cmd_f", this);
   endfunction : build_phase 

   function void write(shortint t);
      shortint predicted_result;
      string data_str;
      command_s cmd; 
      cmd.A = 0;
      cmd.B = 0;
      cmd.op = no_op;
      
      do
        if (!cmd_f.try_get(cmd))
          `uvm_fatal("SCOREBOARD", "Missing command in self checker")
      while ((cmd.op == no_op) || (cmd.op == rst_op));

      case (cmd.op)
        add_op: predicted_result = cmd.A + cmd.B + 1; //force an error on adds
        and_op: predicted_result = cmd.A & cmd.B;
        xor_op: predicted_result = cmd.A ^ cmd.B;
        mul_op: predicted_result = cmd.A * cmd.B;
      endcase // case (op_set)

      data_str = $sformatf(" %2h %0s %2h = %4h (%4h predicted)",
                           cmd.A, cmd.op.name() ,cmd.B, t,  predicted_result);

      if (predicted_result != t) 
        `uvm_error ("SCOREBOARD", {"FAIL: ",data_str})
      else
        `uvm_info ( "SCOREBOARD", {"PASS: ",data_str}, UVM_HIGH)
  
   endfunction : write
      
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new
endclass : scoreboard






