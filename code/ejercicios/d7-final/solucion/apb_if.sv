// The APB interface: the pins, the clock, the protocol and the monitor hook.
// It is the same idea applied to a real bus -- everything that knows HOW the DUT is
// talked to lives here, in one place.
interface apb_if;
   import apb_pkg::*;

   // What the master drives is bit, not logic: it starts at 0 and does not have
   // to be initialized from anywhere. What the slave drives is wire.
   bit          PCLK;
   bit          PRESETn;
   bit          PSEL;
   bit          PENABLE;
   bit          PWRITE;
   bit  [ 7:0]  PADDR;
   bit  [31:0]  PWDATA;
   wire [31:0]  PRDATA;
   wire         PREADY;
   wire         PSLVERR;

   apb_monitor  monitor_h;

   initial begin
      PCLK = 0;
      forever #10 PCLK = ~PCLK;
   end

   // --- el protocolo ---------------------------------------------------------

   task automatic reset();
      PSEL    = 1'b0;
      PENABLE = 1'b0;
      PWRITE  = 1'b0;
      PADDR   = 8'h00;
      PWDATA  = 32'h0;
      PRESETn = 1'b0;
      repeat (2) @(negedge PCLK);
      PRESETn = 1'b1;
   endtask : reset

   // A whole transfer: SETUP, ACCESS, and the wait for PREADY. The read's wait
   // state is NOT counted in cycles -- it waits for the handshake, which is
   // the only thing the spec promises.
   task automatic transfer(input bit wr, input bit [7:0] addr, input bit [31:0] wdata,
                           output bit [31:0] rdata, output bit slverr);
      @(negedge PCLK);          // SETUP
      PSEL    = 1'b1;
      PENABLE = 1'b0;
      PWRITE  = wr;
      PADDR   = addr;
      PWDATA  = wdata;
      @(negedge PCLK);          // ACCESS
      PENABLE = 1'b1;
      do @(posedge PCLK); while (PREADY !== 1'b1);
      rdata  = PRDATA;          // PRDATA y PSLVERR valen en ESTE flanco
      slverr = PSLVERR;
      @(negedge PCLK);
      PSEL    = 1'b0;
      PENABLE = 1'b0;
   endtask : transfer

   // --- the monitor ----------------------------------------------------------
   // It watches the bus and does not drive it: that is why it also sees the transfers of the
   // usual module, which calls none of the tasks above.
   always @(posedge PCLK) begin : bus_monitor
      if (monitor_h != null && PSEL && PENABLE && PREADY)
         monitor_h.write_to_monitor(PWRITE, PADDR, PWDATA, PRDATA, PSLVERR);
   end : bus_monitor

endinterface : apb_if
