package tinyalu_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"
   
      typedef enum bit[2:0] {no_op  = 3'b000,
                          add_op = 3'b001, 
                          and_op = 3'b010,
                          xor_op = 3'b011,
                          mul_op = 3'b100,
                          rst_op = 3'b111} operation_t;
   

   typedef struct {
      byte unsigned        A;
      byte unsigned        B;
      operation_t op;
   } command_s;


   

`include "coverage.svh"
`include "base_tester.svh"
`include "random_tester.svh"
`include "add_tester.svh"   
`include "scoreboard.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
   
`include "env.svh"

`include "random_test.svh"
`include "add_test.svh"
   
endpackage : tinyalu_pkg
   