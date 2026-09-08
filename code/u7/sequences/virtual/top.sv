// El top del ejemplo de sequences virtuales.
//
// Es el de la seccion Sequences menos una linea: NO esta el vtalu_tester_module. Las
// dos VTALU las maneja el testbench, cada una con su agent activo, y por eso
// hay dos sequencers que coordinar -- que es todo el tema.
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

   // En la seccion Sequences esta la manejaba el modulo del jefe y el agent era
   // pasivo. Los nombres quedan a proposito: asi se ve que lo unico que cambia
   // es el is_active del env.
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
