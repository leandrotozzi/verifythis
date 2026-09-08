package vtalu_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   typedef enum bit [2:0] {
      no_op  = 3'b000,
      add_op = 3'b001,
      sub_op = 3'b010,
      and_op = 3'b011,
      xor_op = 3'b100,
      mul_op = 3'b101,
      rst_op = 3'b111
   } operation_t;

   virtual vtalu_bfm bfm_g;

   `include "coverage.svh"
   `include "random_tester.svh"
   `include "add_tester.svh"
   `include "scoreboard.svh"
   `include "random_test.svh"
   `include "add_test.svh"

endpackage : vtalu_pkg
