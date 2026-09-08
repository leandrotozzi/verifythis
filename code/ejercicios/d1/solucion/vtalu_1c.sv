// Las operaciones de un ciclo: add, sub, and, xor. Registra A op B en el flanco.
//
// La resta es la unica que puede desbordar: con operandos de 8 bits y resultado
// de 16, ni la suma ni la multiplicacion se pasan. A - B con A < B si, y por eso
// existe ovf_1c. El resultado en ese caso es el complemento a dos truncado a 16
// bits -- envuelve a 0xFFxx --, que es lo que hace el hardware y lo que el
// scoreboard tiene que predecir bien.
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

   // Los dos resets son distintos a proposito: el del resultado es SINCRONO y
   // el del done es ASINCRONO. No es un descuido, es la spec.
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
            3'b110:  result_1c <= {8'h00, A} >> B[2:0];
            default: ;
         endcase
      end
   end

   // done sube en el flanco si start esta arriba y la op no es no_op
   always_ff @(posedge clk or negedge reset_n) begin
      if (!reset_n) done_1c <= 1'b0;
      else done_1c <= start && (op != 3'b000);
   end

endmodule : vtalu_1c
