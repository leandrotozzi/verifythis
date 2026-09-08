module top;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   // Nuestras clases y macros, igual que en la version modular.
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
      // null y "*": desde la raiz y visible para todo el arbol. Ver la slide
      // de uvm_config_db.
      uvm_config_db#(virtual vtalu_bfm)::set(null, "*", "bfm", bfm);

      // UVM lee +UVM_TESTNAME, y crea ESE test con la factory.
      run_test();
   end

endmodule : top
