class scoreboard extends uvm_subscriber #(result_transaction);
   `uvm_component_utils(scoreboard);


   uvm_tlm_analysis_fifo #(command_transaction) cmd_f;
   
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      cmd_f = new ("cmd_f", this);
   endfunction : build_phase

   function result_transaction predict_result(command_transaction cmd);
       result_transaction predicted;
          
       predicted = new("predicted");
          
       case (cmd.op)
         add_op: predicted.result = cmd.A + cmd.B;
         and_op: predicted.result = cmd.A & cmd.B;
         xor_op: predicted.result = cmd.A ^ cmd.B;
         mul_op: predicted.result = cmd.A * cmd.B;
       endcase // case (op_set)

       return predicted;

   endfunction : predict_result
   

   function void write(result_transaction t);
      string data_str;
      command_transaction cmd;
      result_transaction predicted;

      do
        if (!cmd_f.try_get(cmd))
          $fatal(1, "Missing command in self checker");
      while ((cmd.op == no_op) || (cmd.op == rst_op));

      predicted = predict_result(cmd);
      
      data_str = {                    cmd.convert2string(), 
                  " ==>  Actual "  ,    t.convert2string(), 
                  "/Predicted ",predicted.convert2string()};
                  
                  
      if (!predicted.compare(t))
        `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
      else
        `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)

   endfunction : write
endclass : scoreboard