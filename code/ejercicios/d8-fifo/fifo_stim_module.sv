// The usual module: it drives the FIFO by hand, without UVM. It comes done, and it is
// not touched.
//
// It only runs with +STIM, which is what the checker passes to monitor_test.
// It does TWELVE cycles with activity -- writes, reads and a simultaneous one --
// and your monitor has to see them all and not one more.
module fifo_stim_module (fifo_if bfm);

   // The protocol is one cycle long: the signals go up on the falling edge
   // and the DUT takes them on the rising one. Same as the VTALU BFM.
   task automatic ciclo(input bit wr, input bit [7:0] dato, input bit rd);
      @(negedge bfm.clk);
      bfm.wr_en   = wr;
      bfm.wr_data = dato;
      bfm.rd_en   = rd;
      @(negedge bfm.clk);
      bfm.wr_en = 1'b0;
      bfm.rd_en = 1'b0;
   endtask : ciclo

   initial begin
      bfm.wr_en   = 1'b0;
      bfm.rd_en   = 1'b0;
      bfm.wr_data = 8'h00;
      bfm.rst_n   = 1'b0;
      repeat (2) @(negedge bfm.clk);
      bfm.rst_n = 1'b1;

      // Only with +STIM: in the tests the testbench drives, this FIFO
      // stays quiet.
      if ($test$plusargs("STIM")) begin
         ciclo(1, 8'hA0, 0);  // 1  escribe
         ciclo(1, 8'hA1, 0);  // 2
         ciclo(1, 8'hA2, 0);  // 3
         ciclo(0, 8'h00, 1);  // 4  lee: A0 sale en el ciclo 5
         ciclo(1, 8'hA3, 1);  // 5  simultanea: entra A3 y sale A1
         ciclo(0, 8'h00, 1);  // 6
         ciclo(0, 8'h00, 1);  // 7
         ciclo(0, 8'h00, 1);  // 8  la FIFO queda vacia
         ciclo(0, 8'h00, 1);  // 9  lee vacia: NO pasa nada, y no es un error
         ciclo(1, 8'hB0, 0);  // 10
         ciclo(1, 8'hB1, 0);  // 11
         ciclo(0, 8'h00, 1);  // 12
      end
   end

endmodule : fifo_stim_module
