interface clk_bfm;
   bit clk;
   initial clk = 0;
   always #7 clk = ~clk;
endinterface : clk_bfm


module top;
   import uvm_pkg::*;
`include "uvm_macros.svh"

   import example_pkg::*;

   clk_bfm clk_bfm_i();

   initial begin
      example_pkg::clk_bfm_i = clk_bfm_i;
      run_test("communication_test");
   end

endmodule : top
