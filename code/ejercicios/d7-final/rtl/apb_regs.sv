// El DUT del capstone: un esclavo APB3 con cuatro registros.
//
// La spec esta en spec.md, y es lo unico que hay que leer para verificarlo.
// Este archivo NO se toca: si tu testbench necesita cambiar el RTL para pasar,
// el que esta mal es el testbench.
//
// La unica licencia que se tomo es bug_en, que no existiria en un DUT de
// verdad: con +BUG=1 el acumulador deja de mirar CTRL.EN. Esta para que puedas
// comprobar que tu scoreboard chequea algo -- un scoreboard que nunca vio un
// error no esta probado.
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

   // El mapa entra en 16 bytes: cuatro registros de 32 bits. PADDR[1:0] se
   // ignora; de 0x10 para arriba no hay nadie y se contesta con PSLVERR.
   wire mapped = (PADDR < 8'h10);
   wire access = PSEL && PENABLE;

   // El handshake: la escritura no espera, la lectura mete UN wait state.
   // rd_wait se rearma en cuanto baja PENABLE, o sea entre transferencia y
   // transferencia, sin necesidad de contar ciclos.
   logic rd_wait;
   always_ff @(posedge PCLK or negedge PRESETn) begin
      if (!PRESETn) rd_wait <= 1'b1;
      else if (!PENABLE) rd_wait <= 1'b1;
      else if (access && !PWRITE) rd_wait <= 1'b0;
   end

   assign PREADY  = !PSEL ? 1'b1 : (PWRITE ? 1'b1 : !rd_wait);
   assign PSLVERR = access && !mapped;

   // El ciclo en que la transferencia realmente ocurre: es el unico flanco que
   // le importa al monitor, y el unico en que el DUT cambia de estado.
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
               // El acumulador solo corre con EN=1. Es la unica linea que
               // +BUG=1 rompe.
               if (en || bug_en) begin
                  acc <= suma[31:0];
                  if (suma[32]) ovf <= 1'b1;  // pegajoso hasta el proximo CLR
               end
            end
            default: ;  // ACC y STATUS son de solo lectura: la escritura se ignora
         endcase
      end
   end

endmodule : apb_regs
