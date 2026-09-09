// The FIFO interface: the pins, the clock, the protocol and the monitor
// hook. Everything that knows HOW the DUT is talked to lives here.
interface fifo_if;
   import fifo_pkg::*;

   // What the testbench drives is bit; what the DUT drives is wire.
   bit         clk;
   bit         rst_n;
   bit         wr_en;
   bit  [7:0]  wr_data;
   bit         rd_en;
   wire        full;
   wire        almost_full;
   wire [7:0]  rd_data;
   wire        empty;
   wire        almost_empty;
   wire [3:0]  count;

   fifo_monitor monitor_h;

   initial begin
      clk = 0;
      forever #10 clk = ~clk;
   end

   // --- el protocolo ---------------------------------------------------------

   task automatic reset();
      wr_en   = 1'b0;
      rd_en   = 1'b0;
      wr_data = 8'h00;
      rst_n   = 1'b0;
      repeat (2) @(negedge clk);
      rst_n = 1'b1;
   endtask : reset

   // One cycle: the signals go up on the falling edge and the DUT takes them
   // on the rising one. There is no handshake to wait for -- the FIFO always serves,
   // and when it cannot, it discards. That is half the spec.
   task automatic ciclo(input bit wr, input bit [7:0] dato, input bit rd);
      @(negedge clk);
      wr_en   = wr;
      wr_data = dato;
      rd_en   = rd;
      @(negedge clk);
      wr_en = 1'b0;
      rd_en = 1'b0;
   endtask : ciclo

   // --- the monitor ----------------------------------------------------------
   // It watches and does not drive, so it also sees the cycles of the usual module.
   //
   // The two publications come from the same edge and are not the same thing:
   //   - the CYCLE: what was asked for, and with which flags. The flags are read here,
   //     before the edge changes them -- they describe the state in which the
   //     FIFO serves this cycle.
   //   - the DATUM: rd_data is REGISTERED, so what is read now is the
   //     answer to the read of the PREVIOUS cycle. That is why saco_prev is needed.
   bit saco_prev;
   always @(posedge clk) begin : fifo_bus_monitor
      if (monitor_h != null && rst_n) begin
         if (saco_prev) monitor_h.write_dato(rd_data);
         monitor_h.write_ciclo(wr_en, wr_data, rd_en,
                               full, almost_full, empty, almost_empty, count);
      end
      saco_prev <= rst_n && rd_en && !empty;
   end : fifo_bus_monitor

endinterface : fifo_if
