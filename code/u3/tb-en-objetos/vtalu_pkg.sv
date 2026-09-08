package vtalu_pkg;
   typedef enum bit [2:0] {
      no_op  = 3'b000,
      add_op = 3'b001,
      sub_op = 3'b010,
      and_op = 3'b011,
      xor_op = 3'b100,
      mul_op = 3'b101,
      rst_op = 3'b111
   } operation_t;

   `include "coverage.svh"
   `include "tester.svh"
   `include "scoreboard.svh"
   `include "testbench.svh"
endpackage : vtalu_pkg

