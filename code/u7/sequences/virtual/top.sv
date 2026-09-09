// The top of the virtual sequences example.
//
// It is the one from the Sequences section minus one line: there is NO vtalu_tester_module. Both
// VTALUs are driven by the testbench, each with its own active agent, and that is
// why there are two sequencers to coordinate -- which is the whole topic.
module top;
   import uvm_pkg::*;
   import vtalu_pkg::*;
   `include "uvm_macros.svh"

   vtalu_bfm clase_bfm ();
   vtalu clase_dut (
       .A(clase_bfm.A), .B(clase_bfm.B), .op(clase_bfm.op_set),
       .clk(clase_bfm.clk), .reset_n(clase_bfm.reset_n), .start(clase_bfm.start),
       .done(clase_bfm.done),
       .ovf(clase_bfm.ovf), .result(clase_bfm.result)
   );

   // In the Sequences section this one was driven by the boss's module and the agent
   // was passive. The names are kept on purpose: that way it is visible that the
   // only thing that changes is the env's is_active.
   vtalu_bfm modulo_bfm ();
   vtalu modulo_dut (
       .A(modulo_bfm.A), .B(modulo_bfm.B), .op(modulo_bfm.op_set),
       .clk(modulo_bfm.clk), .reset_n(modulo_bfm.reset_n), .start(modulo_bfm.start),
       .done(modulo_bfm.done),
       .ovf(modulo_bfm.ovf), .result(modulo_bfm.result)
   );

   initial begin
      uvm_config_db#(virtual vtalu_bfm)::set(null, "*", "clase_bfm", clase_bfm);
      uvm_config_db#(virtual vtalu_bfm)::set(null, "*", "modulo_bfm", modulo_bfm);
      run_test();
   end

endmodule : top
