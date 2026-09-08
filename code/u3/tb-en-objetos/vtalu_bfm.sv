interface vtalu_bfm;
   import vtalu_pkg::*;

   byte unsigned        A;
   byte unsigned        B;
   bit                  clk;
   bit                  reset_n;
   bit                  start;
   wire                 done;
   wire          [15:0] result;
   wire                 ovf;
   operation_t          op_set;

   initial begin
      clk = 0;
      forever begin
         #10;
         clk = ~clk;
      end
   end


   // --- el protocolo, en el BFM ---
   // Todo lo que sabe COMO se habla con el DUT vive aca, en un solo lugar: el
   // resto del testbench pide una operacion y no toca un cable. Es la idea de
   // la unidad 3, y se sostiene hasta el final del curso.

   task reset_alu();
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start = 1'b0;
   endtask : reset_alu

   task send_op(input byte iA, input byte iB, input operation_t iop,
                output shortint alu_result);

      if (iop == rst_op) begin
         @(posedge clk);
         reset_n = 1'b0;
         start = 1'b0;
         @(posedge clk);
         #1;
         reset_n = 1'b1;
      end else begin
         @(negedge clk);
         op_set = iop;
         A = iA;
         B = iB;
         start = 1'b1;
         if (iop == no_op) begin
            @(posedge clk);
            #1;
            start = 1'b0;
         end else begin
            do @(negedge clk); while (done == 0);
            start = 1'b0;
         end
         alu_result = result;
      end  // else: !if(iop == rst_op)

   endtask : send_op

endinterface : vtalu_bfm
