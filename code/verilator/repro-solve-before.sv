// Minimal repro: Verilator 5.052 accepts "solve ... before" and does not honour it.
//
//   $ verilator --binary --timing --top-module top -o sim repro-solve-before.sv
//   ./obj_dir/sim
//
// Expected (LRM 1800-2017, 18.5.10): with "solve es_reset before A" the solver
// picks es_reset first and uniformly, that is ~50 %.
// Observed on 5.052: es_reset stays stuck at 0 -- 0 out of 2000. Without the
// directive it gives ~0,4 % (1 in every 257 solutions), which IS what the LRM says.
// So the directive is not ignored: it makes the bias it came to fix worse.
//
// Portable workaround meanwhile: ask for the split of the control field with a
// dist, which Verilator does honour. See code/u6/transactions/constraints/03_solve.sv.
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
         if (s.randomize() == 0) $fatal(1, "randomize() failed");
         if (s.es_reset) ns = ns + 1;
         if (c.randomize() == 0) $fatal(1, "randomize() failed");
         if (c.es_reset) nc = nc + 1;
      end

      $display("no solve...before  : es_reset=1 %0d/%0d (%0.1f%%)  expected ~0,4%%",
               ns, N, 100.0 * ns / N);
      $display("with solve...before : es_reset=1 %0d/%0d (%0.1f%%)  expected ~50%%",
               nc, N, 100.0 * nc / N);
      $finish;
   end

endmodule
