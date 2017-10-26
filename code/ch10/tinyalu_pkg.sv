package tinyalu_pkg;
      typedef enum bit[2:0] {no_op  = 3'b000,
                             add_op = 3'b001, 
                             and_op = 3'b010,
                             xor_op = 3'b011,
                             mul_op = 3'b100,
                             rst_op = 3'b111} operation_t;


`include "coverage.svh"
`include "tester.svh"
`include "scoreboard.svh"
`include "testbench.svh"
endpackage : tinyalu_pkg
   