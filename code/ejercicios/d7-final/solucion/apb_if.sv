// La interface del APB: los pines, el reloj, el protocolo y el enganche del
// monitor. Es la unidad 3 aplicada a un bus de verdad -- todo lo que sabe COMO
// se habla con el DUT vive aca, en un solo lugar.
interface apb_if;
   import apb_pkg::*;

   // Lo que maneja el maestro es bit, no logic: arranca en 0 y no hay que
   // inicializarlo desde ningun lado. Lo que maneja el esclavo es wire.
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

   // Una transferencia entera: SETUP, ACCESS, y la espera por PREADY. El wait
   // state de la lectura NO se cuenta en ciclos -- se espera al handshake, que
   // es lo unico que la spec promete.
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

   // --- el monitor -----------------------------------------------------------
   // Mira el bus y no lo maneja: por eso ve tambien las transferencias del
   // modulo de siempre, que no llama a ninguna de las tasks de arriba.
   always @(posedge PCLK) begin : bus_monitor
      if (monitor_h != null && PSEL && PENABLE && PREADY)
         monitor_h.write_to_monitor(PWRITE, PADDR, PWDATA, PRDATA, PSLVERR);
   end : bus_monitor

endinterface : apb_if
