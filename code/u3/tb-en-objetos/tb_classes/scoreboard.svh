class scoreboard;
   virtual vtalu_bfm bfm;

   function new(virtual vtalu_bfm b);
      bfm = b;
   endfunction : new

   // The always @(posedge done) of the modular version, as a forever loop: an
   // object has no sensitivity list, it has a task that blocks.
   task execute();
      shortint predicted_result;
      bit      predicted_ovf;
      forever begin : self_checker
         @(posedge bfm.done) #1;
         case (bfm.op_set)
            add_op: predicted_result = bfm.A + bfm.B;
            sub_op: predicted_result = bfm.A - bfm.B;
            and_op: predicted_result = bfm.A & bfm.B;
            xor_op: predicted_result = bfm.A ^ bfm.B;
            mul_op: predicted_result = bfm.A * bfm.B;
         endcase  // case (op_set)

         // ovf belongs to sub and to nobody else: with 8-bit inputs and a 16-bit
         // output, neither the addition nor the multiplication can overflow.
         predicted_ovf = (bfm.op_set == sub_op) && (bfm.A < bfm.B);

         if ((bfm.op_set != no_op) && (bfm.op_set != rst_op))
            if (predicted_result != bfm.result || predicted_ovf != bfm.ovf)
               $error(
                   "FAILED: A: %0h  B: %0h  op: %s result: %0h ovf: %0b",
                   bfm.A,
                   bfm.B,
                   bfm.op_set.name(),
                   bfm.result,
                   bfm.ovf
               );

      end : self_checker
   endtask : execute

endclass : scoreboard
