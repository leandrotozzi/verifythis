// Constrained Random 3 -- the solve order biases without warning.
//
// The constraint below looks harmless and is the classic trap: the solver picks
// uniformly among the SOLUTIONS, not among the values of each field.
// With es_reset=1 there is a single solution (A=00); with es_reset=0 there are 256.
// Result: the reset gets asked for 1 in every 257 times, and the "any
// operation after a reset" bin of the Functional coverage section plan never fills.
module top_solve;

   class sesgada;
      rand bit           es_reset;
      rand byte unsigned A;
      constraint c {es_reset -> A == 8'h00;}
   endclass

   // The language's answer is "solve es_reset before A": pick the control field
   // FIRST and then solve the rest. Verilator 5.052 accepts the syntax and does
   // NOT honour it -- it leaves es_reset stuck at 0, which is worse than
   // ignoring it. Repro in code/verilator/repro-solve-before.sv.
   //
   // The workaround that IS portable: ask explicitly for the split of the
   // control field. It says the same and does not rely on the solver ordering well.
   class pareja extends sesgada;
      constraint reparto {es_reset dist {1'b0 :/ 1, 1'b1 :/ 1};}
   endclass

   localparam int N = 2000;

   initial begin
      sesgada s;
      pareja  p;
      int s_reset, p_reset;

      s = new();
      p = new();

      repeat (N) begin
         if (!s.randomize()) $fatal(1, "sesgada randomize() failed");
         if (s.es_reset) s_reset = s_reset + 1;

         if (!p.randomize()) $fatal(1, "pareja randomize() failed");
         if (p.es_reset) p_reset = p_reset + 1;
      end

      $display("%0d randomizations of each version", N);
      $display("  as written             es_reset=1 in %5.1f%%   (1 in 257)",
               100.0 * s_reset / N);
      $display("  with dist on es_reset  es_reset=1 in %5.1f%%", 100.0 * p_reset / N);
      $finish;
   end

endmodule : top_solve
