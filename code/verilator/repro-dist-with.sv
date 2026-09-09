// Minimal repro: in Verilator 5.052, a dist is not solved together with the rest
// of the constraints. A concrete value of the dist is picked FIRST and only then
// is everything else checked; if the picked value does not satisfy it,
// randomize() returns 0 instead of looking for another one.
//
//   $ verilator --binary --timing --top-module top -o sim repro-dist-with.sv
//   $ ./obj_dir/sim
//
// With  A dist {8'h00 :/ 1, [8'h01:8'hFE] :/ 2, 8'hFF :/ 1}  the success rate of
// a randomize() with {} is neither 0 nor 100: it is the PROBABILITY that the
// drawn value satisfies the restriction. Measured over 400 randomizations:
//
//   with {A == 8'hFF}          ~25 %   the weight of the FF bin (1 of 4)
//   with {A inside {[1:10]}}    ~2 %   10 values of the 254 in the middle bin, x 50 %
//   with {A != 8'h00}          ~75 %   fails only when the 00 bin is drawn
//   with {B == 8'hFF}          100 %   B has no dist: it is unaffected
//
// So it is NOT "with over a class that has a dist". It is: the with restricts a
// field that has a dist. A field without dist in the same class always solves.
//
// That is why an intermittent directed case is the typical symptom, and why it is
// dangerous: it passes on your machine and fails in the regression. Workaround:
// turn the dist off with constraint_mode(0) before the with, which for a directed
// stimulus adds nothing. code/u6/transactions/constraints/02_with.sv uses it.
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
      $display("  with {A == 8'hFF}          %5.1f%%   expected ~25%%  (weight of the FF bin)",
               100.0 * ff / N);
      $display("  with {A inside {[1:10]}}   %5.1f%%   esperado  ~2%%  (10 de 254, x 50%%)",
               100.0 * rango / N);
      $display("  with {A != 8'h00}          %5.1f%%   esperado ~75%%",
               100.0 * distinto / N);
      $display("  with {B == 8'hFF}          %5.1f%%   B has no dist",
               100.0 * sin_dist / N);

      // The workaround: with no dist in the way, the directed request always solves.
      c.data.constraint_mode(0);
      repeat (N) if (c.randomize() with {A == 8'hFF;}) apagado = apagado + 1;
      $display("  + data.constraint_mode(0)  %5.1f%%   esperado 100%%",
               100.0 * apagado / N);
      $finish;
   end

endmodule
