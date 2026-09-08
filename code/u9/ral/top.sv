// The top of the RAL example. One APB slave -- the capstone DUT -- and one
// interface. There is no second bus here: the passive agent of the capstone was
// there so the monitor had something to watch before the driver existed, and by
// this unit the driver exists.
module top;
   import uvm_pkg::*;
   import apb_pkg::*;
   import ral_pkg::*;
   `include "uvm_macros.svh"

   apb_if bfm ();

   apb_regs dut (
       .PCLK(bfm.PCLK), .PRESETn(bfm.PRESETn), .PSEL(bfm.PSEL), .PENABLE(bfm.PENABLE),
       .PWRITE(bfm.PWRITE), .PADDR(bfm.PADDR), .PWDATA(bfm.PWDATA), .bug_en(1'b0),
       .PRDATA(bfm.PRDATA), .PREADY(bfm.PREADY), .PSLVERR(bfm.PSLVERR)
   );

   initial begin
      uvm_config_db#(virtual apb_if)::set(null, "*", "bfm", bfm);
      run_test();
   end

endmodule : top
