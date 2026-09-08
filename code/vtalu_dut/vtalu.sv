// VTALU top: A, B, clk, op[2:0], reset_n, start -> done, ovf, result[15:0].
//
// The op is NOT decided by a single loose bit any more: there is a decode, which
// is what a real design does, and what lets the operations avoid having to sit
// in tidy halves of the opcode space.
//
//   no_op  3'b000      and_op 3'b011
//   add_op 3'b001      xor_op 3'b100
//   sub_op 3'b010      mul_op 3'b101
//                      3'b110 free -- the day 1 exercise
//   rst_op 3'b111 never reaches the DUT: the BFM turns it into lowering reset_n
module vtalu (
    input  logic [ 7:0] A,
    input  logic [ 7:0] B,
    input  logic        clk,
    input  logic [ 2:0] op,
    input  logic        reset_n,
    input  logic        start,
    output logic        done,
    output logic        ovf,
    output logic [15:0] result
);

   logic done_1c, done_mult;
   logic ovf_1c;
   logic [15:0] result_1c, result_mult;
   logic start_1c, start_mult;
   logic es_mult;

   assign es_mult = (op == 3'b101);

   assign start_1c = es_mult ? 1'b0 : start;
   assign start_mult = es_mult ? start : 1'b0;
   assign result = es_mult ? result_mult : result_1c;
   assign done = es_mult ? done_mult : done_1c;

   // The multiplication cannot overflow: 8 x 8 fits exactly in 16 bits.
   assign ovf = es_mult ? 1'b0 : ovf_1c;

   vtalu_1c u_1c (
       .A        (A),
       .B        (B),
       .clk      (clk),
       .op       (op),
       .reset_n  (reset_n),
       .start    (start_1c),
       .done_1c  (done_1c),
       .ovf_1c   (ovf_1c),
       .result_1c(result_1c)
   );

   vtalu_mult u_mult (
       .A          (A),
       .B          (B),
       .clk        (clk),
       .reset_n    (reset_n),
       .start      (start_mult),
       .done_mult  (done_mult),
       .result_mult(result_mult)
   );

endmodule : vtalu
