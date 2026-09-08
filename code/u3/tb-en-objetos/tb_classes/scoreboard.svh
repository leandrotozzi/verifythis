class scoreboard;
   virtual vtalu_bfm bfm;

   function new(virtual vtalu_bfm b);
      bfm = b;
   endfunction : new

   // El always @(posedge done) de la version modular, como forever loop: un
   // objeto no tiene lista de sensibilidad, tiene una task que se bloquea.
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

         // El ovf es del sub y de nadie mas: con 8 bits de entrada y 16 de
         // salida, ni la suma ni la multiplicacion se pasan.
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
