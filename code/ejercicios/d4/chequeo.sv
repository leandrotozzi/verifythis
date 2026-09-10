// The checker of the day 4 exercise, plugged in from outside the testbench.
//
// It is bound into the top, so nobody has to connect it -- and connecting things
// is exactly what this exercise is about, so it could not depend on the env.
// Do not touch it: run.sh checks its hash in intocables.sha before compiling.
//
// It counts one thing, off the bus: the multiplications that really went by.
// That number moves with the seed and nobody can know it in advance, which is
// what makes "multiplications=" in your report_phase a measurement and not a
// literal. The commands are cross-checked against the lines the command_monitor
// prints, and that monitor comes from u5: you do not write it either.
module chequeo_d4;
   import vtalu_pkg::*;

   int muls = 0;

   // One rising edge of start per command the BFM puts on the bus.
   always @(posedge top.bfm.start) if (top.bfm.op_set == mul_op) muls++;

   final $display("[CHEQUEO] muls=%0d", muls);

endmodule : chequeo_d4

bind top chequeo_d4 chequeo_i();
