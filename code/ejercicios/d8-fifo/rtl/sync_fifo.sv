// The DUT of the second capstone: a synchronous FIFO with backpressure.
//
// The spec is in spec.md, and it is the only thing to read in order to verify it.
// This file is NOT touched: if your testbench needs to change the RTL to pass,
// the one that is wrong is the testbench.
//
// The only liberty taken is bug_en, which would not exist in a real DUT:
// with +BUG=1, almost_full goes up one place late. It is there so that
// you can check that your scoreboard checks something, and it is no accident that the bug
// is on a FLAG: a scoreboard that only compares the data coming out passes
// green and sees nothing.
module sync_fifo #(
    parameter int DEPTH = 8,   // lugares
    parameter int AF    = 6,   // almost_full a partir de aca, INCLUSIVE
    parameter int AE    = 2    // almost_empty up to here, INCLUSIVE
) (
    input  logic       clk,
    input  logic       rst_n,

    // lado de escritura
    input  logic       wr_en,
    input  logic [7:0] wr_data,
    output logic       full,
    output logic       almost_full,

    // lado de lectura
    input  logic       rd_en,
    output logic [7:0] rd_data,
    output logic       empty,
    output logic       almost_empty,

    output logic [3:0] count,
    input  logic       bug_en
);

   // The parameters arrive as int: in 4 bits so that comparisons against
   // ocupados do not drag a WIDTHEXPAND onto every line.
   localparam logic [3:0] N_DEPTH = 4'(DEPTH);
   localparam logic [3:0] N_AF    = 4'(AF);
   localparam logic [3:0] N_AE    = 4'(AE);

   logic [7:0] mem[DEPTH];
   logic [2:0] wr_ptr, rd_ptr;
   logic [3:0] ocupados;

   // The flags come from the occupancy BEFORE the edge: they are combinational,
   // so what the driver sees in a cycle describes the state in which the
   // FIFO is going to serve that cycle.
   assign count        = ocupados;
   assign full         = (ocupados == N_DEPTH);
   assign empty        = (ocupados == 0);
   assign almost_empty = (ocupados <= N_AE);
   assign almost_full  = bug_en ? (ocupados >= N_AF + 4'd1) : (ocupados >= N_AF);

   // Who goes in and who goes out on THIS edge. The read frees a place in the
   // same cycle, so a write simultaneous with a read goes in even when
   // the FIFO is full. And the other way round: a read on an empty FIFO takes
   // nothing out even when there is a simultaneous write, because the datum enters at the end
   // of the queue, not at the front.
   wire saca = rd_en && !empty;
   wire mete = wr_en && (!full || saca);

   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         wr_ptr   <= '0;
         rd_ptr   <= '0;
         ocupados <= '0;
         rd_data  <= '0;
      end else begin
         if (mete) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr      <= wr_ptr + 1'b1;
         end
         // rd_data is REGISTERED: the datum appears the cycle AFTER the one it
         // was asked for. It is trap number one of this spec.
         if (saca) begin
            rd_data <= mem[rd_ptr];
            rd_ptr  <= rd_ptr + 1'b1;
         end
         ocupados <= ocupados + (mete ? 4'd1 : 4'd0) - (saca ? 4'd1 : 4'd0);
      end
   end

endmodule : sync_fifo
