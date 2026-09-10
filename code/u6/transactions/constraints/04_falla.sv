// Constrained Random 4 -- when randomize() returns 0, and how to switch things off.
//
// randomize() neither aborts nor prints anything on its own: it returns 0 and
// carries on. If nobody looks at the return value, the testbench sends an
// unrandomized transaction and the bug shows up three components later.
module top_falla;

   // cb: the-unsolvable
   class comando;
      rand byte unsigned A;
      constraint chico {A < 8'h10;}
      constraint grande {A > 8'hF0;}  // contradicts the previous one: no solution
   endclass

   initial begin
      comando c;
      c = new();

      // 1. Both constraints active: there is no A that satisfies the two.
      if (!c.randomize()) $display("1. randomize() returned 0: the constraints do not close");
      else $display("1. randomize() gave %2h  (should not get here)", c.A);

      // 2. constraint_mode(0) turns a constraint off at run time.
      c.grande.constraint_mode(0);
      if (!c.randomize()) $display("2. randomize() returned 0  (should not get here)");
      else $display("2. with 'grande' turned off: A=%2h, and it honours 'chico'", c.A);

      // 3. rand_mode(0) takes the field out of the draw: it keeps its current value.
      c.A.rand_mode(0);
      if (!c.randomize()) $display("3. randomize() returned 0  (should not get here)");
      else $display("3. with A out of the draw: A=%2h, the same as before", c.A);

      $finish;
   // cb: end
   end

endmodule : top_falla
