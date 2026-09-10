// The one-cycle operations: add, sub, and, xor. Registers A op B on the edge.
//
// The subtraction is the only one that can overflow: with 8-bit operands and a
// 16-bit result, neither the addition nor the multiplication go over. A - B with
// A < B does, and that is why ovf_1c exists. The result in that case is the two's
// complement truncated to 16 bits -- it wraps to 0xFFxx --, which is what the
// hardware does and what the scoreboard has to predict correctly.
module vtalu_1c (
    input  logic [ 7:0] A,
    input  logic [ 7:0] B,
    input  logic        clk,
    input  logic [ 2:0] op,
    input  logic        reset_n,
    input  logic        start,
    output logic        done_1c,
    output logic        ovf_1c,
    output logic [15:0] result_1c
);

   // The two resets are different on purpose: the one on the result is SYNCHRONOUS
   // and the one on done is ASYNCHRONOUS. It is not an oversight, it is the spec.
   always_ff @(posedge clk) begin
      if (!reset_n) begin
         result_1c <= 16'h0000;
         ovf_1c    <= 1'b0;
      end else if (start) begin
         ovf_1c <= (op == 3'b010) && (A < B);
         case (op)
            3'b001:  result_1c <= {8'h00, A} + {8'h00, B};
            3'b010:  result_1c <= {8'h00, A} - {8'h00, B};
            3'b011:  result_1c <= {8'h00, A} & {8'h00, B};
            3'b100:  result_1c <= {8'h00, A} ^ {8'h00, B};
            // TODO(exercise d1): 3'b110 is free. The shift goes here.
            default: ;
         endcase
      end
   end

   // done goes up on the edge if start is up and the op is not no_op
   always_ff @(posedge clk or negedge reset_n) begin
      if (!reset_n) done_1c <= 1'b0;
      else done_1c <= start && (op != 3'b000);
   end

endmodule : vtalu_1c
