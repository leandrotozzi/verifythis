interface tinyalu_bfm;
   // guardamos operation_t. Ej: (no_op  = 3'b000)
   import tinyalu_pkg::*;

   byte         unsigned        A;
   byte         unsigned        B;
   bit          clk;
   bit          reset_n;
   wire [2:0]   op;
   bit          start;
   wire         done;
   wire [15:0]  result;
   operation_t  op_set;

   assign op = op_set;

   // BFM nos da un primer paso en la modularizacion
   // Se encarga de manejar todas las signals de bajo nivel
   // encapsulando el protocolo en un mismo y unico lugar

   // Clock del DUT
   initial begin
      clk = 0;
      forever begin
         #10;
         clk = ~clk;
      end
   end

   // Reset del DUT
   task reset_alu();
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start = 1'b0;
   endtask : reset_alu
  
  // Podemos modificar el manejo del protocolo en un unico lugar. 
  // Si arreglamos el Fix Aca, se propaga en el resto del codigo 
  task send_op(input byte iA, input byte iB, input operation_t iop, output shortint alu_result);
     
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
            do
              @(negedge clk);
            while (done == 0);
            start = 1'b0;
         end
      end
      
   endtask : send_op

endinterface : tinyalu_bfm