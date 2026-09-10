// The usual module: it drives its APB by hand, without UVM and without the
// interface tasks. It comes done, and it is not touched.
//
// It only runs with +STIM, which is what the checker passes to monitor_test.
// There are EIGHT transfers, and all eight respect the protocol. Your monitor has
// to see them all and not one more.
//
// With +BUG=2 they are still eight and the handshake is still the same, but the
// module moves PADDR in the middle of ACCESS -- which the protocol forbids. The
// monitor sees eight tidy transfers, the scoreboard has nothing to complain
// about, and the only thing that notices is an assertion. That is stage 5.
module apb_stim_module (apb_if bfm);

   int bug;   // +BUG=2 is this module's; +BUG=1 is the DUT's, see top.sv

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
      // The protocol violation of +BUG=2: PADDR has to stay put from SETUP until
      // the transfer ends. Bit 2 is flipped, which lands on another mapped
      // register (and 0x10 stays unmapped), so the DUT answers as usual and the
      // reconstructed transaction is consistent with what it did.
      if (bug == 2) bfm.PADDR = addr ^ 8'h04;
      do @(posedge bfm.PCLK); while (bfm.PREADY !== 1'b1);
      @(negedge bfm.PCLK);
      bfm.PSEL = 1'b0;
      bfm.PENABLE = 1'b0;
   endtask : xfer

   initial begin
      bug = 0;
      void'($value$plusargs("BUG=%d", bug));
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
         xfer(0, 8'h10, 32'h0);          // outside the map: PSLVERR
         xfer(0, 8'h0C, 32'h0);          // lee STATUS
      end
   end

endmodule : apb_stim_module
