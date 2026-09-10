// The checker of the day 2 exercise, plugged in from outside the testbench.
//
// It is bound into the top, so it starts on its own: it does not depend on
// testbench.svh creating it, and testbench.svh is one of the files the exercise
// edits. Do not touch it -- see intocables.sha.
module chequeo_d2;
   import vtalu_pkg::*;

   chequeo chequeo_h;

   initial begin
      chequeo_h = new(top.bfm);
      chequeo_h.mira();
   end

   // The two draws go in the final block on purpose: get_op() consumes $random,
   // and doing it here leaves the stimulus of the run exactly as it was.
   final begin
      tester base_h;
      base_h = new(top.bfm);
      $display("[CHEQUEO] base_draws=%0d dispatch=%0d muls=%0d others=%0d",
               chequeo_h.variety(base_h),
               chequeo_h.variety(top.testbench_h.tester_h),
               chequeo_h.muls, chequeo_h.others);
   end

endmodule : chequeo_d2

bind top chequeo_d2 chequeo_i();
