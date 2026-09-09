module top;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   // Our classes and macros, same as in the modular version.
   import vtalu_pkg::*;
   `include "vtalu_macros.svh"

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
      // null and "*": from the root and visible to the whole tree. See the
      // uvm_config_db slide.
      uvm_config_db#(virtual vtalu_bfm)::set(null, "*", "bfm", bfm);

      // UVM reads +UVM_TESTNAME, and builds THAT test with the factory.
      run_test();
   end

endmodule : top
