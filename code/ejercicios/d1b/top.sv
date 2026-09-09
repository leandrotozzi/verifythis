// The top of the conventional testbench, with the wave dump turned on: it is the
// only exercise in the course that gets solved by looking at the .vcd.
module top;
   vtalu_bfm bfm ();
   tester tester_i (bfm);
   coverage coverage_i (bfm);
   scoreboard scoreboard_i (bfm);

   vtalu DUT (
       .A(bfm.A), .B(bfm.B), .op(bfm.op), .clk(bfm.clk),
       .reset_n(bfm.reset_n), .start(bfm.start),
       .done(bfm.done), .ovf(bfm.ovf), .result(bfm.result)
   );

`ifdef VLT_TRACE
   // Waves for GTKWave:  VLT_TRACE=1 bash run.sh  &&  gtkwave ondas.vcd
   // Behind an `ifdef because $dumpvars does not compile without --trace, and
   // the define comes from the same VLT_TRACE that adds the flag (common.sh).
   initial begin
      $dumpfile("ondas.vcd");
      $dumpvars;
   end
`endif
endmodule : top
