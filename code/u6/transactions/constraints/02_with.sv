// Constrained Random 2 -- inside, y randomize() with {}.
//
// La constraint de la clase da el grueso del estimulo. El caso dirigido se pide
// en el punto de uso, sin tocar la clase y sin escribir un tester nuevo.
module top_with;

   typedef enum bit [2:0] {
      no_op  = 3'b000,
      add_op = 3'b001,
      sub_op = 3'b010,
      and_op = 3'b011,
      xor_op = 3'b100,
      mul_op = 3'b101,
      rst_op = 3'b111
   } operation_t;

   class comando;
      rand byte unsigned A;
      rand byte unsigned B;
      rand operation_t   op;

      constraint data {
         A dist {8'h00 :/ 1, [8'h01 : 8'hFE] :/ 2, 8'hFF :/ 1};
         B dist {8'h00 :/ 1, [8'h01 : 8'hFE] :/ 2, 8'hFF :/ 1};
      }

      // inside es un conjunto de valores legales. Sin esto el random tambien
      // pide no_op y rst_op, que no calculan nada.
      constraint utiles {op inside {add_op, and_op, xor_op, mul_op};}
   endclass

   localparam int N = 400;

   initial begin
      comando c;
      int maximos;

      c = new();

      // El bin mul_max de la cobertura de la seccion Cobertura funcional: una multiplicacion con
      // las dos patas en 0xFF. Es el desborde del multiplicador.
      repeat (N) begin
         if (!c.randomize()) $fatal(1, "randomize() fallo");
         if (c.op == mul_op && c.A == 8'hFF && c.B == 8'hFF) maximos = maximos + 1;
      end
      $display("al azar:  %0d intentos, mul_max se lleno %0d vez/veces", N, maximos);

      // Lo mismo, pedido: with {} agrega constraints SOLO para esta llamada.
      // El pedido es satisfacible, pero en 5.052 el dist se resuelve eligiendo
      // un valor ANTES de chequear el with: si el sorteado no cumple, devuelve
      // 0 en vez de reintentar. Con A y B en dist, que las dos caigan en 0xFF
      // es 1/4 x 1/4. Las tasas medidas estan en
      // code/verilator/repro-dist-with.sv; el detalle en docs/verilator.md.
      if (!c.randomize() with {
            op == mul_op;
            A  == 8'hFF;
            B  == 8'hFF;
          })
         $display("con with: randomize() dio 0  <- limitacion de Verilator, no tuya");

      // El rodeo portable mientras tanto: apagar el reparto, que para un caso
      // dirigido no tiene sentido de todos modos.
      c.data.constraint_mode(0);
      if (!c.randomize() with {
            op == mul_op;
            A  == 8'hFF;
            B  == 8'hFF;
          })
         $fatal(1, "randomize() with fallo hasta con la constraint apagada");
      $display("con with: 1 intento,   A=%2h %s B=%2h", c.A, c.op.name(), c.B);
      $finish;
   end

endmodule : top_with
