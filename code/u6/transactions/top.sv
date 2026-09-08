module top;
   import uvm_pkg::*;
   import vtalu_pkg::*;
   `include "vtalu_macros.svh"
   `include "uvm_macros.svh"

vtalu_bfm bfm ();
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

   initial begin
      uvm_config_db#(virtual vtalu_bfm)::set(null, "*", "bfm", bfm);
      run_test();
   end

endmodule : top

