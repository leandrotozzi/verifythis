interface vtalu_bfm;
   // guardamos operation_t. Ej: (no_op  = 3'b000)
   import vtalu_pkg::*;

   byte unsigned        A;
   byte unsigned        B;
   bit                  clk;
   bit                  reset_n;
   wire          [ 2:0] op;
   bit                  start;
   wire                 done;
   wire          [15:0] result;
   wire                 ovf;
   operation_t          op_set;

   assign op = op_set;

   // The BFM is a first step towards modularity
   // It takes care of driving every low-level signal
   // and keeps the protocol in one single place

   // DUT clock
   initial begin
      clk = 0;
      forever begin
         #10;
         clk = ~clk;
      end
   end

   // DUT reset
   task reset_alu();
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start = 1'b0;
   endtask : reset_alu

   // The protocol handling can now be changed in one single place.
   // Fix it here once, and the fix propagates through the rest of the code
   task send_op(input byte iA, input byte iB, input operation_t iop,
                output shortint alu_result);

      op_set = iop;

      if (iop == rst_op) begin
         @(posedge clk);
         reset_n = 1'b0;
         start = 1'b0;
         @(posedge clk);
         #1;
         reset_n = 1'b1;
      end else begin
         @(negedge clk);
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
      end

   endtask : send_op

endinterface : vtalu_bfm
