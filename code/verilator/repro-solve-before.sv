// Repro minimo: Verilator 5.052 acepta "solve ... before" y no lo respeta.
//
//   $ verilator --binary --timing --top-module top -o sim repro-solve-before.sv
//   ./obj_dir/sim
//
// Esperado (LRM 1800-2017, 18.5.10): con "solve es_reset before A" el solver
// elige es_reset primero y uniforme, o sea ~50 %.
// Observado en 5.052: es_reset queda clavado en 0 -- 0 de 2000. Sin la
// directiva da ~0,4 % (1 de cada 257 soluciones), que SI es lo que dice la LRM.
// O sea que la directiva no se ignora: empeora el sesgo que venia a arreglar.
//
// Rodeo portable mientras tanto: pedir el reparto del campo de control con un
// dist, que Verilator si respeta. Ver code/u6/transactions/constraints/03_solve.sv.
module top;

   class sin_directiva;
      rand bit           es_reset;
      rand byte unsigned A;
      constraint c {es_reset -> A == 8'h00;}
   endclass

   class con_directiva extends sin_directiva;
      constraint orden {solve es_reset before A;}
   endclass

   localparam int N = 2000;

   initial begin
      sin_directiva s;
      con_directiva c;
      int ns, nc;

      s = new();
      c = new();

      repeat (N) begin
         if (s.randomize() == 0) $fatal(1, "randomize() fallo");
         if (s.es_reset) ns = ns + 1;
         if (c.randomize() == 0) $fatal(1, "randomize() fallo");
         if (c.es_reset) nc = nc + 1;
      end

      $display("sin solve...before : es_reset=1 %0d/%0d (%0.1f%%)  esperado ~0,4%%",
               ns, N, 100.0 * ns / N);
      $display("con solve...before : es_reset=1 %0d/%0d (%0.1f%%)  esperado ~50%%",
               nc, N, 100.0 * nc / N);
      $finish;
   end

endmodule
