module top;
   import uvm_pkg::*;
   import tinyalu_pkg::*;
   
   `include "tinyalu_macros.svh"
   `include "uvm_macros.svh"
   
   tinyalu_bfm bfm();
   tinyalu DUT (.A(bfm.A), .B(bfm.B), .op(bfm.op), 
                .clk(bfm.clk), .reset_n(bfm.reset_n), 
                .start(bfm.start), .done(bfm.done), .result(bfm.result));

initial begin
   tinyalu_pkg::bfm_g = bfm;
   uvm_config_db #(virtual tinyalu_bfm)::set(null, "*", "bfm", bfm);
   run_test();
end

endmodule : top

     
   