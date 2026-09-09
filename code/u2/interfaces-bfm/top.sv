module top;
   vtalu_bfm bfm ();
   // Tester: generates the stimulus
   tester tester_i (bfm);
   // Coverage: provides functional coverage
   coverage coverage_i (bfm);
   // ScoreBoard: checks the results
   scoreboard scoreboard_i (bfm);

   vtalu DUT (
       .A(bfm.A),
       .B(bfm.B),
       .op(bfm.op),
       .clk(bfm.clk),
       .reset_n(bfm.reset_n),
       .start(bfm.start),
       .done(bfm.done),
       .ovf(bfm.ovf),
       .result(bfm.result)
   );
endmodule : top
