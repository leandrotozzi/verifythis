// El top del testbench convencional, con el volcado de ondas prendido: es el
// unico ejercicio del curso que se resuelve mirando el .vcd.
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
   // Ondas para GTKWave:  VLT_TRACE=1 bash run.sh  &&  gtkwave ondas.vcd
   // Va detras de un `ifdef porque $dumpvars no compila sin --trace, y el
   // define lo pone el mismo VLT_TRACE que agrega el flag (common.sh).
   initial begin
      $dumpfile("ondas.vcd");
      $dumpvars;
   end
`endif
endmodule : top
