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

      // Las dos lecturas, en el MISMO instante, sobre el MISMO cable.
      por_cb = bfm.cb.d_out;
      crudo  = bfm.d_out;

      $display("en el mismo instante, sobre el mismo cable:");
      $display("  bfm.cb.d_out (lo que muestreo el clocking block) : %0d", por_cb);
      $display("  bfm.d_out    (el cable, en vivo)                 : %0d", crudo);
      $display("");
      $display("Difieren en un ciclo, y ningun warning lo dice. Un monitor que");
      $display("lea por el clocking block y un scoreboard que lea el cable");
      $display("crudo no fallan siempre: fallan cuando el dato cambia.");

      if (por_cb == crudo)
        $fatal(1, "se esperaba que difirieran: el ejemplo dejo de mostrar la trampa");
      $finish;
   end
endmodule : top_mezcla
