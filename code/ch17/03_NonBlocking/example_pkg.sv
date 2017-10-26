package example_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   virtual clk_bfm clk_bfm_i;

   `include "producer.svh"
   `include "consumer.svh"
   `include "communication_test.svh"
endpackage : example_pkg

   
     
   