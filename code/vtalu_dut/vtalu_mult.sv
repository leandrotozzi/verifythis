// Multi-cycle multiplication: done rises on the FOURTH clock edge after start
// (the one-cycle ops raise it on the first). The latency is deliberate: it is
// what forces the testbench to wait for 'done' instead of counting cycles.
module vtalu_mult (
    input  logic [ 7:0] A,
    input  logic [ 7:0] B,
    input  logic        clk,
    input  logic        reset_n,
    input  logic        start,
    output logic        done_mult,
    output logic [15:0] result_mult
);

   logic [7:0] a_int, b_int;  // input registers
   logic [15:0] mult1, mult2;  // pipeline registers
   logic done3, done2, done1;  // done travels down the same pipeline

   // cb: the-pipeline
   // Four register stages. done is pipelined alongside the data, and each
   // stage clears itself with (& ~done_mult): that is what makes done a
   // one-cycle pulse instead of staying high for as long as start does. It is
   // subtle -- it is copied straight from the VHDL.
   always_ff @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         done_mult <= 1'b0;
         done3 <= 1'b0;
         done2 <= 1'b0;
         done1 <= 1'b0;
         a_int <= 8'h00;
         b_int <= 8'h00;
         mult1 <= 16'h0000;
         mult2 <= 16'h0000;
         result_mult <= 16'h0000;
      end else begin
         a_int <= A;
         b_int <= B;
         mult1 <= a_int * b_int;
         mult2 <= mult1;
         result_mult <= mult2;
         done3 <= start & ~done_mult;
         done2 <= done3 & ~done_mult;
         done1 <= done2 & ~done_mult;
         done_mult <= done1 & ~done_mult;
      end
   end
   // cb: end

endmodule : vtalu_mult
