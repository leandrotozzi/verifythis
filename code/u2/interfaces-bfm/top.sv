module top;
   vtalu_bfm bfm ();
   // Tester: Genera el estimulo
   tester tester_i (bfm);
   // Coverage: Provee Functional Coverage
   coverage coverage_i (bfm);
   // ScoreBoard: Chequea los resultados
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
