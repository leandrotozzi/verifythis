// The usual module: it drives its APB by hand, without UVM and without the
// interface tasks. It comes done, and it is not touched.
//
// It only runs with +STIM, which is what the checker passes to monitor_test.
// There are EIGHT transfers, and all eight respect the protocol. Your monitor has
// to see them all and not one more.
module apb_stim_module (apb_if bfm);

   // The protocol written by hand, just like whoever wrote this did in
   // 2014: SETUP on a falling edge, ACCESS on the next one, and PREADY
   // sampled on the rising one.
   task automatic xfer(input bit wr, input bit [7:0] addr, input bit [31:0] data);
      @(negedge bfm.PCLK);
      bfm.PSEL = 1'b1;
      bfm.PENABLE = 1'b0;
      bfm.PWRITE = wr;
      bfm.PADDR = addr;
      bfm.PWDATA = data;
      @(negedge bfm.PCLK);
      bfm.PENABLE = 1'b1;
      do @(posedge bfm.PCLK); while (bfm.PREADY !== 1'b1);
      @(negedge bfm.PCLK);
      bfm.PSEL = 1'b0;
      bfm.PENABLE = 1'b0;
   endtask : xfer

   initial begin
      bfm.PSEL = 1'b0;
      bfm.PENABLE = 1'b0;
      bfm.PWRITE = 1'b0;
      bfm.PADDR = 8'h00;
      bfm.PWDATA = 32'h0;
      bfm.PRESETn = 1'b0;
      repeat (2) @(negedge bfm.PCLK);
      bfm.PRESETn = 1'b1;

      // Only with +STIM: in the tests the testbench drives, this bus
      // stays quiet.
      if ($test$plusargs("STIM")) begin
         xfer(1, 8'h00, 32'h0000_0001);  // EN = 1
         xfer(1, 8'h04, 32'h0000_0010);  // SCRATCH, ACC = 0x10
         xfer(1, 8'h04, 32'h0000_0020);  // SCRATCH, ACC = 0x30
         xfer(0, 8'h08, 32'h0);          // lee ACC
         xfer(0, 8'h04, 32'h0);          // lee SCRATCH
         xfer(1, 8'h08, 32'h0000_00FF);  // escribe ACC: se ignora, y NO da error
         xfer(0, 8'h10, 32'h0);          // fuera del mapa: PSLVERR
         xfer(0, 8'h0C, 32'h0);          // lee STATUS
      end
   end

endmodule : apb_stim_module
