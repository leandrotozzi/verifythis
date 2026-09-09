// The capstone top. It comes done, and it is not touched.
//
// There are TWO slaves, each with its own interface -- it is the same arrangement as the
// Agents section: one is driven by your testbench, the other by a module of
// always, without a line of UVM. The second one exists so that you can write the
// MONITOR before the driver, which is the order the bus appendix recommends:
// if you cannot see the bus, you cannot verify anything.
module top;
   import uvm_pkg::*;
   import apb_pkg::*;
   `include "uvm_macros.svh"

   bit bug_en;
   int bug;

   // The one your testbench drives
   apb_if bfm ();
   apb_regs dut (
       .PCLK(bfm.PCLK), .PRESETn(bfm.PRESETn), .PSEL(bfm.PSEL), .PENABLE(bfm.PENABLE),
       .PWRITE(bfm.PWRITE), .PADDR(bfm.PADDR), .PWDATA(bfm.PWDATA), .bug_en(bug_en),
       .PRDATA(bfm.PRDATA), .PREADY(bfm.PREADY), .PSLVERR(bfm.PSLVERR)
   );

   // The one the usual module drives. Its DUT never has the bug: the only thing
   // looked at there is whether your monitor sees the bus.
   apb_if stim_bfm ();
   apb_regs stim_dut (
       .PCLK(stim_bfm.PCLK), .PRESETn(stim_bfm.PRESETn), .PSEL(stim_bfm.PSEL),
       .PENABLE(stim_bfm.PENABLE), .PWRITE(stim_bfm.PWRITE), .PADDR(stim_bfm.PADDR),
       .PWDATA(stim_bfm.PWDATA), .bug_en(1'b0),
       .PRDATA(stim_bfm.PRDATA), .PREADY(stim_bfm.PREADY), .PSLVERR(stim_bfm.PSLVERR)
   );

   apb_stim_module stim (stim_bfm);

   initial begin
      // The number matters: +BUG=1 is the DUT's (the CTRL.EN gate), +BUG=2 is
      // the usual module's (it moves PADDR during ACCESS). $test$plusargs("BUG")
      // would say yes to both, so it is read as a value.
      bug = 0;
      void'($value$plusargs("BUG=%d", bug));
      bug_en = (bug == 1);
      // As in the Sequences section: the top leaves the two interfaces with a name and walks
      // away. Handing them out is the test's job.
      uvm_config_db#(virtual apb_if)::set(null, "*", "bfm", bfm);
      uvm_config_db#(virtual apb_if)::set(null, "*", "stim_bfm", stim_bfm);
      run_test();
   end

endmodule : top
