module top;
   import uvm_pkg::*;
   import vtalu_pkg::*;
   `include "vtalu_macros.svh"
   `include "uvm_macros.svh"

   // La VTALU que maneja el testbench de clases
   vtalu_bfm clase_bfm ();
   vtalu clase_dut (
       .A(clase_bfm.A), .B(clase_bfm.B), .op(clase_bfm.op_set),
       .clk(clase_bfm.clk), .reset_n(clase_bfm.reset_n), .start(clase_bfm.start),
       .done(clase_bfm.done),
       .ovf(clase_bfm.ovf), .result(clase_bfm.result)
   );

   // La VTALU que maneja el modulo heredado
   vtalu_bfm modulo_bfm ();
   vtalu modulo_dut (
       .A(modulo_bfm.A), .B(modulo_bfm.B), .op(modulo_bfm.op_set),
       .clk(modulo_bfm.clk), .reset_n(modulo_bfm.reset_n), .start(modulo_bfm.start),
       .done(modulo_bfm.done),
       .ovf(modulo_bfm.ovf), .result(modulo_bfm.result)
   );

   vtalu_tester_module stim_module (modulo_bfm);

   initial begin
      // El top no sabe nada de agents: deja las dos interfaces con nombre y
      // se va. Quien las reparte es el test.
      uvm_config_db#(virtual vtalu_bfm)::set(null, "*", "clase_bfm", clase_bfm);
      uvm_config_db#(virtual vtalu_bfm)::set(null, "*", "modulo_bfm", modulo_bfm);
      run_test();
   end

endmodule : top
