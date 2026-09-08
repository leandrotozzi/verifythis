// The RAL layer, and nothing else. Everything below it -- the interface with the
// APB protocol, the transaction, the driver, the monitor and the agent -- comes
// from the capstone solution, unchanged, through the +incdir of run.sh.
//
// That is the whole point of the unit: RAL is a layer on top of a testbench that
// already works, not a different testbench.
package ral_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"
   import apb_pkg::*;

   `include "apb_reg_block.svh"
   `include "apb_reg_adapter.svh"
   `include "ral_base_test.svh"
   `include "mapa_test.svh"
   `include "ral_test.svh"
   `include "builtin_test.svh"

endpackage : ral_pkg
