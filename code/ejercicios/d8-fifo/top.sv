// El top del segundo capstone. Se da hecho, y no se toca.
//
// Hay DOS FIFOs, cada una con su interface -- el mismo arreglo del capstone del
// APB y de la seccion Agents: una la maneja tu testbench, la otra la maneja un
// modulo de siempre. La segunda existe para que puedas escribir el MONITOR
// antes que el driver.
module top;
   import uvm_pkg::*;
   import fifo_pkg::*;
   `include "uvm_macros.svh"

   bit bug_en;

   // La que maneja tu testbench
   fifo_if bfm ();
   sync_fifo dut (
       .clk(bfm.clk), .rst_n(bfm.rst_n),
       .wr_en(bfm.wr_en), .wr_data(bfm.wr_data),
       .full(bfm.full), .almost_full(bfm.almost_full),
       .rd_en(bfm.rd_en), .rd_data(bfm.rd_data),
       .empty(bfm.empty), .almost_empty(bfm.almost_empty),
       .count(bfm.count), .bug_en(bug_en)
   );

   // La que maneja el modulo de siempre. Su DUT nunca tiene el bug: lo unico
   // que se mira ahi es si tu monitor ve la FIFO.
   fifo_if stim_bfm ();
   sync_fifo stim_dut (
       .clk(stim_bfm.clk), .rst_n(stim_bfm.rst_n),
       .wr_en(stim_bfm.wr_en), .wr_data(stim_bfm.wr_data),
       .full(stim_bfm.full), .almost_full(stim_bfm.almost_full),
       .rd_en(stim_bfm.rd_en), .rd_data(stim_bfm.rd_data),
       .empty(stim_bfm.empty), .almost_empty(stim_bfm.almost_empty),
       .count(stim_bfm.count), .bug_en(1'b0)
   );

   fifo_stim_module stim (stim_bfm);

   initial begin
      bug_en = $test$plusargs("BUG");
      uvm_config_db#(virtual fifo_if)::set(null, "*", "bfm", bfm);
      uvm_config_db#(virtual fifo_if)::set(null, "*", "stim_bfm", stim_bfm);
      run_test();
   end

endmodule : top
