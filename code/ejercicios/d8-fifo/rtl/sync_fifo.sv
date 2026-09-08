// El DUT del segundo capstone: una FIFO sincronica con backpressure.
//
// La spec esta en spec.md, y es lo unico que hay que leer para verificarlo.
// Este archivo NO se toca: si tu testbench necesita cambiar el RTL para pasar,
// el que esta mal es el testbench.
//
// La unica licencia que se tomo es bug_en, que no existiria en un DUT de
// verdad: con +BUG=1, almost_full se levanta un lugar tarde. Esta para que
// puedas comprobar que tu scoreboard chequea algo, y no es casual que el bug
// sea de una BANDERA: un scoreboard que solo compara los datos que salen pasa
// en verde y no ve nada.
module sync_fifo #(
    parameter int DEPTH = 8,   // lugares
    parameter int AF    = 6,   // almost_full a partir de aca, INCLUSIVE
    parameter int AE    = 2    // almost_empty hasta aca, INCLUSIVE
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

   // Los parametros vienen como int: en 4 bits para que las comparaciones con
   // ocupados no arrastren un WIDTHEXPAND en cada linea.
   localparam logic [3:0] N_DEPTH = 4'(DEPTH);
   localparam logic [3:0] N_AF    = 4'(AF);
   localparam logic [3:0] N_AE    = 4'(AE);

   logic [7:0] mem[DEPTH];
   logic [2:0] wr_ptr, rd_ptr;
   logic [3:0] ocupados;

   // Las banderas salen de la ocupacion ANTES del flanco: son combinacionales,
   // asi que lo que el driver ve en un ciclo describe el estado en el que la
   // FIFO va a atender ese ciclo.
   assign count        = ocupados;
   assign full         = (ocupados == N_DEPTH);
   assign empty        = (ocupados == 0);
   assign almost_empty = (ocupados <= N_AE);
   assign almost_full  = bug_en ? (ocupados >= N_AF + 4'd1) : (ocupados >= N_AF);

   // Quien entra y quien sale en ESTE flanco. La lectura libera un lugar en el
   // mismo ciclo, asi que una escritura simultanea a una lectura entra aunque
   // la FIFO este llena. Y al reves: una lectura sobre una FIFO vacia no saca
   // nada aunque haya una escritura simultanea, porque el dato entra al final
   // de la cola, no al principio.
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
         // rd_data esta REGISTRADO: el dato aparece el ciclo SIGUIENTE al que
         // se pidio. Es la trampa numero uno de esta spec.
         if (saca) begin
            rd_data <= mem[rd_ptr];
            rd_ptr  <= rd_ptr + 1'b1;
         end
         ocupados <= ocupados + (mete ? 4'd1 : 4'd0) - (saca ? 4'd1 : 4'd0);
      end
   end

endmodule : sync_fifo
