// The trap that comes with the clocking block: mixing the two domains.
//
// Once a signal belongs to a clocking block, there are TWO names for the same
// wire -- bfm.d_out and bfm.cb.d_out -- and they are NOT the same value. One is
// the live wire; the other is what the clocking block sampled #1step before the
// edge. On a signal that changes every cycle they differ by exactly one cycle.
//
// Nothing warns about this: it compiles, it runs, and a scoreboard that reads
// one of them while the monitor reads the other fails intermittently.
//
//   bash run.sh
module contador (input bit clk, output byte unsigned d_out);
   // Counts on every edge, so the live wire and the sampled one never agree.
   always_ff @(posedge clk) d_out <= d_out + 8'd1;
endmodule

interface cnt_bfm (input bit clk);
   byte unsigned d_out;
   clocking cb @(posedge clk);
      default input #1step;
      input d_out;
   endclocking
endinterface : cnt_bfm

module top_mezcla;
   bit clk = 0;
   always #5 clk = ~clk;

   cnt_bfm bfm (clk);
   contador u_cnt (.clk(clk), .d_out(bfm.d_out));

   byte unsigned por_cb, crudo;

   initial begin
      repeat (4) @(bfm.cb);
// cb: two-reads

      // The two reads, at the SAME instant, on the SAME wire.
      por_cb = bfm.cb.d_out;
      crudo  = bfm.d_out;

      $display("at the same instant, on the same wire:");
      $display("  bfm.cb.d_out (what the clocking block sampled) : %0d", por_cb);
      $display("  bfm.d_out    (the live wire)                   : %0d", crudo);
      $display("");
      $display("They differ by one cycle, and no warning says so. A monitor that");
      $display("reads through the clocking block and a scoreboard that reads the");
// cb: end
      $display("raw wire do not fail every time: they fail when the data changes.");

      if (por_cb == crudo)
        $fatal(1, "they were expected to differ: the example stopped showing the trap");
      $finish;
   end
endmodule : top_mezcla
