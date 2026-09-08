// Repro minimo: en Verilator 5.052, un dist no se resuelve junto con el resto
// de las constraints. Se elige un valor concreto del dist PRIMERO y recien
// despues se chequea lo demas; si el valor elegido no lo cumple, randomize()
// devuelve 0 en vez de buscar otro.
//
//   $ verilator --binary --timing --top-module top -o sim repro-dist-with.sv
//   $ ./obj_dir/sim
//
// Con  A dist {8'h00 :/ 1, [8'h01:8'hFE] :/ 2, 8'hFF :/ 1}  la tasa de exito de
// un randomize() with {} no es 0 ni 100: es la PROBABILIDAD de que el valor
// sorteado cumpla la restriccion. Medido sobre 400 randomizaciones:
//
//   with {A == 8'hFF}          ~25 %   el peso del bin FF (1 de 4)
//   with {A inside {[1:10]}}    ~2 %   10 valores de los 254 del bin del medio, x 50 %
//   with {A != 8'h00}          ~75 %   falla solo cuando sortea el bin 00
//   with {B == 8'hFF}          100 %   B no tiene dist: no lo afecta
//
// O sea que NO es "with sobre una clase con dist". Es: el with restringe un
// campo que tiene dist. Un campo sin dist en la misma clase resuelve siempre.
//
// Por eso un caso dirigido intermitente es el sintoma tipico, y por eso es
// peligroso: pasa en la maquina de uno y falla en la regresion. Rodeo: apagar
// el dist con constraint_mode(0) antes del with, que para un estimulo dirigido
// no aporta nada. Lo usa code/u6/transactions/constraints/02_with.sv.
module top;

   class comando;
      rand byte unsigned A;
      rand byte unsigned B;
      constraint data {A dist {8'h00 :/ 1, [8'h01 : 8'hFE] :/ 2, 8'hFF :/ 1};}
   endclass

   localparam int N = 400;

   initial begin
      comando c;
      int ff, rango, distinto, sin_dist, apagado;

      c = new();

      repeat (N) begin
         if (c.randomize() with {A == 8'hFF;}) ff = ff + 1;
         if (c.randomize() with {A inside {[1 : 10]};}) rango = rango + 1;
         if (c.randomize() with {A != 8'h00;}) distinto = distinto + 1;
         if (c.randomize() with {B == 8'hFF;}) sin_dist = sin_dist + 1;
      end

      $display("%0d randomizaciones de cada forma", N);
      $display("  with {A == 8'hFF}          %5.1f%%   esperado ~25%%  (peso del bin FF)",
               100.0 * ff / N);
      $display("  with {A inside {[1:10]}}   %5.1f%%   esperado  ~2%%  (10 de 254, x 50%%)",
               100.0 * rango / N);
      $display("  with {A != 8'h00}          %5.1f%%   esperado ~75%%",
               100.0 * distinto / N);
      $display("  with {B == 8'hFF}          %5.1f%%   B no tiene dist",
               100.0 * sin_dist / N);

      // El rodeo: sin el dist en el camino, el pedido dirigido resuelve siempre.
      c.data.constraint_mode(0);
      repeat (N) if (c.randomize() with {A == 8'hFF;}) apagado = apagado + 1;
      $display("  + data.constraint_mode(0)  %5.1f%%   esperado 100%%",
               100.0 * apagado / N);
      $finish;
   end

endmodule
