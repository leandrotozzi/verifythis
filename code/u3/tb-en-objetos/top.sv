module top;

   // Class definitions and shared resources are kept in a package
   import vtalu_pkg::*;
   // The macros are defined in common too. UVM does this as well
   `include "vtalu_macros.svh"

   // The DUT and the BFM get instantiated
   vtalu DUT (
       .A(bfm.A),
       .B(bfm.B),
       .op(bfm.op_set),
       .clk(bfm.clk),
       .reset_n(bfm.reset_n),
       .start(bfm.start),
       .done(bfm.done),
       .ovf(bfm.ovf),
       .result(bfm.result)
   );

   vtalu_bfm bfm ();

   // A variable to hold our TB
   testbench testbench_h;

   initial begin
      // The testbench object gets built and launched
      testbench_h = new(bfm);
      testbench_h.execute();
   end

endmodule : top
