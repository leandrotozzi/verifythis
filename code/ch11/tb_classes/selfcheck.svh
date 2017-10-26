class scoreboard;
      virtual tinyalu_bfm bfm;

   function new (virtual tinyalu_bfm b);
     bfm = b;
   endfunction : new

   task execute();
      shortint predicted_result;
      forever begin : self_checker
         @(posedge bfm.done) 
           case (bfm.op_set)
             add_op: predicted_result = bfm.A + bfm.B;
             and_op: predicted_result = bfm.A & bfm.B;
             xor_op: predicted_result = bfm.A ^ bfm.B;
             mul_op: predicted_result = bfm.A * bfm.B;
           endcase // case (op_set)
         
         if ((bfm.op_set != no_op) && (bfm.op_set != rst_op))
           if (predicted_result != bfm.result)
             $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                     bfm.A, bfm.B, bfm.op_set.name(), bfm.result);
         
      end : self_checker
   endtask : execute
   
   
endclass : scoreboard






