// La interface de la FIFO: los pines, el reloj, el protocolo y el enganche del
// monitor. Todo lo que sabe COMO se habla con el DUT vive aca.
interface fifo_if;
   import fifo_pkg::*;

   // Lo que maneja el testbench es bit; lo que maneja el DUT es wire.
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

   // Un ciclo: se levantan las senales en el flanco de bajada y el DUT las toma
   // en el de subida. No hay handshake que esperar -- la FIFO atiende siempre,
   // y si no puede, descarta. Esa es la mitad de la spec.
   task automatic ciclo(input bit wr, input bit [7:0] dato, input bit rd);
      @(negedge clk);
      wr_en   = wr;
      wr_data = dato;
      rd_en   = rd;
      @(negedge clk);
      wr_en = 1'b0;
      rd_en = 1'b0;
   endtask : ciclo

   // --- el monitor -----------------------------------------------------------
   // Mira y no maneja, asi que ve tambien los ciclos del modulo de siempre.
   //
   // Las dos publicaciones salen del mismo flanco y no son lo mismo:
   //   - el CICLO: que se pidio, y con que banderas. Las banderas se leen aca,
   //     antes de que el flanco las cambie -- describen el estado en el que la
   //     FIFO atiende este ciclo.
   //   - el DATO: rd_data esta REGISTRADO, asi que lo que se lee ahora es la
   //     respuesta a la lectura del ciclo ANTERIOR. Por eso hace falta saco_prev.
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
