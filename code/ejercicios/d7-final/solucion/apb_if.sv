// The APB interface: the pins, the clock, the protocol and the monitor hook.
// It is the same idea applied to a real bus -- everything that knows HOW the DUT is
// talked to lives here, in one place.
interface apb_if;
   import uvm_pkg::*;
   import apb_pkg::*;
   `include "uvm_macros.svh"

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
                           input bit b2b, output bit [31:0] rdata, output bit slverr);
      @(negedge PCLK);          // SETUP -- and it drops PENABLE if we come from a b2b
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
      // Back to back: PSEL stays high and the next call turns this edge into the
      // next SETUP. SETUP has to last EXACTLY one cycle, so this only works
      // because the sequence hands over the next item in zero time -- a
      // production driver asks seq_item_port.has_do_available() instead of
      // trusting that. And the last item of a sequence has to come with b2b = 0
      // or the bus is left in ACCESS forever.
      if (!b2b) begin : idle
         @(negedge PCLK);
         PSEL    = 1'b0;
         PENABLE = 1'b0;
      end : idle
   endtask : transfer

   // --- the monitor ----------------------------------------------------------
   // It watches the bus and does not drive it: that is why it also sees the transfers of the
   // usual module, which calls none of the tasks above.
   //
   // encadenada is row 8 of the plan, read off the WIRES and not off the item:
   // PSEL did not go down since the previous transfer. Read that way it works the
   // same for the module that drives its APB by hand.
   bit encadenada;

   always @(posedge PCLK) begin : bus_monitor
      if (!PSEL) encadenada <= 1'b0;
      else if (PENABLE && PREADY) begin : fin_de_transferencia
         if (monitor_h != null)
            monitor_h.write_to_monitor(PWRITE, PADDR, PWDATA, PRDATA, PSLVERR, encadenada);
         encadenada <= 1'b1;
      end : fin_de_transferencia
   end : bus_monitor

   // ==========================================================================
   //  The protocol, checked where it happens  (stage 5)
   // ==========================================================================
   //
   // Same idea as the Assertions section, now on a real bus: the properties live
   // WITH the signals, nobody connects them, and both apb_if instances get them
   // -- including the one driven by the usual module, which nobody asked.
   // They only run with --assert; see run.sh.
   //
   // ONE clock here, unlike the VTALU BFM: everything the master drives moves on
   // the negedge and everything is sampled on the posedge, which is the edge the
   // APB master itself samples PREADY on. So every property is @(posedge PCLK).

   default disable iff (!PRESETn);

   // SETUP lasts exactly one cycle: after a PSEL with PENABLE low comes ACCESS.
   property p_setup_un_ciclo;
      @(posedge PCLK) PSEL && !PENABLE |=> PENABLE;
   endproperty : p_setup_un_ciclo

   a_setup_un_ciclo : assert property (p_setup_un_ciclo)
      else `uvm_error("SVA", $sformatf("%m: SETUP did not go on to ACCESS"))

   // The payload does not move until the transfer ends, and a transfer ends on
   // the edge where PSEL, PENABLE and PREADY are all high. This is the one
   // +BUG=2 trips: the address moves in the middle of ACCESS.
   property p_payload_estable;
      @(posedge PCLK) PSEL && !(PENABLE && PREADY) |=> $stable({PADDR, PWRITE, PWDATA});
   endproperty : p_payload_estable

   a_payload_estable : assert property (p_payload_estable)
      else `uvm_error("SVA", $sformatf("%m: the payload moved before PREADY: PADDR=0x%02h", PADDR))

   // The wait state: ACCESS is held until the handshake, it is not counted in
   // cycles. A driver that gives up during the read's wait state trips here.
   property p_access_hasta_ready;
      @(posedge PCLK) PSEL && PENABLE && !PREADY |=> PSEL && PENABLE;
   endproperty : p_access_hasta_ready

   a_access_hasta_ready : assert property (p_access_hasta_ready)
      else `uvm_error("SVA", $sformatf("%m: ACCESS dropped without PREADY"))

   // And the other side of the same rule: PENABLE only drops after an edge with
   // PREADY high.
   property p_enable_baja_con_ready;
      @(posedge PCLK) $fell(PENABLE) |-> $past(PREADY);
   endproperty : p_enable_baja_con_ready

   a_enable_baja_con_ready : assert property (p_enable_baja_con_ready)
      else `uvm_error("SVA", $sformatf("%m: PENABLE dropped and PREADY was not high"))

   // --- Every assertion comes with its cover property -------------------------
   //
   // And one measured warning that is worth more than a fifth assertion: the
   // obvious reading of "PSLVERR is valid together with PREADY" is
   // `PSLVERR |-> PREADY`, and on THIS DUT it is FALSE. PSLVERR is combinational
   // (PSEL && PENABLE && !mapped), so on an unmapped READ it is already high
   // during the wait state, with PREADY still low. The spec says PSLVERR is only
   // READ on the edge where PREADY is high -- which is a cover, not an assert.
   // Written as an assertion it fires on the healthy DUT: a false positive, and
   // the fastest way to teach a testbench to cry wolf.
   c_slverr        : cover property (@(posedge PCLK) PSEL && PENABLE && PREADY && PSLVERR);
   c_write         : cover property (@(posedge PCLK) PSEL && PENABLE && PREADY &&  PWRITE);
   c_read_espera   : cover property (@(posedge PCLK) PSEL && PENABLE && !PWRITE && !PREADY ##1 PREADY);
   c_back_to_back  : cover property (@(posedge PCLK) PSEL && PENABLE && PREADY ##1 PSEL && !PENABLE);

endinterface : apb_if
