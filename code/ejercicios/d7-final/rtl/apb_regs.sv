// The capstone DUT: an APB3 slave with four registers.
//
// The spec is in spec.md, and it is the only thing to read in order to verify it.
// This file is NOT touched: if your testbench needs to change the RTL to pass,
// the one that is wrong is the testbench.
//
// The only liberty taken is bug_en, which would not exist in a real DUT:
// with +BUG=1 the accumulator stops looking at CTRL.EN. It is there so you can
// check that your scoreboard checks something -- a scoreboard that never saw an
// error is not tested.
module apb_regs (
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [ 7:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        bug_en,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR
);

   logic        en;       // CTRL[0]
   logic        ovf;      // STATUS[1], pegajoso
   logic [31:0] scratch;  // SCRATCH
   logic [31:0] acc;      // ACC

   // The map fits in 16 bytes: four 32-bit registers. PADDR[1:0] is
   // ignored; from 0x10 up there is nobody and the answer is PSLVERR.
   wire mapped = (PADDR < 8'h10);
   wire access = PSEL && PENABLE;

   // cb: handshake
   // The handshake: the write does not wait, the read inserts ONE wait state.
   // rd_wait re-arms as soon as PENABLE drops, that is between one transfer and
   // the next, with no need to count cycles.
   logic rd_wait;
   always_ff @(posedge PCLK or negedge PRESETn) begin
      if (!PRESETn) rd_wait <= 1'b1;
      else if (!PENABLE) rd_wait <= 1'b1;
      else if (access && !PWRITE) rd_wait <= 1'b0;
   end

   assign PREADY  = !PSEL ? 1'b1 : (PWRITE ? 1'b1 : !rd_wait);
   assign PSLVERR = access && !mapped;
   // cb: end

   // The cycle where the transfer actually happens: it is the only edge that
   // matters to the monitor, and the only one where the DUT changes state.
   wire xfer = access && PREADY;

   always_comb begin
      PRDATA = 32'h0;
      if (mapped)
         case (PADDR[3:2])
            2'd0: PRDATA = {31'h0, en};        // CTRL: CLR es autoclear, lee 0
            2'd1: PRDATA = scratch;
            2'd2: PRDATA = acc;
            default: PRDATA = {30'h0, ovf, en};  // STATUS
         endcase
   end

   logic [32:0] suma;
   assign suma = {1'b0, acc} + {1'b0, PWDATA};

   always_ff @(posedge PCLK or negedge PRESETn) begin
      if (!PRESETn) begin
         en      <= 1'b0;
         ovf     <= 1'b0;
         scratch <= 32'h0;
         acc     <= 32'h0;
      end else if (xfer && PWRITE && mapped) begin
         case (PADDR[3:2])
            2'd0: begin
               en <= PWDATA[0];
               if (PWDATA[1]) begin  // CLR
                  acc <= 32'h0;
                  ovf <= 1'b0;
               end
            end
            2'd1: begin
               scratch <= PWDATA;
               // The accumulator only runs with EN=1. It is the only line
               // +BUG=1 breaks.
               if (en || bug_en) begin
                  acc <= suma[31:0];
                  if (suma[32]) ovf <= 1'b1;  // sticky until the next CLR
               end
            end
            default: ;  // ACC and STATUS are read-only: the write is ignored
         endcase
      end
   end

endmodule : apb_regs
