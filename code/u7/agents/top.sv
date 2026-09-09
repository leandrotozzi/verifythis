module top;
   import uvm_pkg::*;
   import vtalu_pkg::*;
   `include "vtalu_macros.svh"
   `include "uvm_macros.svh"

   // The VTALU driven by the class testbench
   vtalu_bfm clase_bfm ();
   vtalu clase_dut (
       .A(clase_bfm.A), .B(clase_bfm.B), .op(clase_bfm.op_set),
       .clk(clase_bfm.clk), .reset_n(clase_bfm.reset_n), .start(clase_bfm.start),
       .done(clase_bfm.done),
       .ovf(clase_bfm.ovf), .result(clase_bfm.result)
   );

   // The VTALU driven by the legacy module
   vtalu_bfm modulo_bfm ();
   vtalu modulo_dut (
       .A(modulo_bfm.A), .B(modulo_bfm.B), .op(modulo_bfm.op_set),
       .clk(modulo_bfm.clk), .reset_n(modulo_bfm.reset_n), .start(modulo_bfm.start),
       .done(modulo_bfm.done),
       .ovf(modulo_bfm.ovf), .result(modulo_bfm.result)
   );

   vtalu_tester_module stim_module (modulo_bfm);

   initial begin
      // The top knows nothing about agents: it leaves the two interfaces with a
      // name and walks away. Handing them out is the test's job.
      uvm_config_db#(virtual vtalu_bfm)::set(null, "*", "clase_bfm", clase_bfm);
      uvm_config_db#(virtual vtalu_bfm)::set(null, "*", "modulo_bfm", modulo_bfm);
      run_test();
   end

endmodule : top
