// El scoreboard es un modelo del DUT escrito en software: los mismos cuatro
// registros, las mismas reglas, y ninguna de las senales. Cada transferencia
// que ve, la aplica o la compara.
//
// El reset no llega hasta aca: en este testbench ocurre una sola vez, antes de
// la primera transferencia, y los campos ya arrancan en cero. Si algun test
// reseteara en el medio, el modelo habria que resetearlo tambien -- y la forma
// de hacerlo es que el monitor reporte el reset, como hace la BFM de la VTALU.
class apb_scoreboard extends uvm_subscriber #(apb_transaction);
   `uvm_component_utils(apb_scoreboard)

   bit          en;
   bit          ovf;
   bit [31:0]   scratch;
   bit [31:0]   acc;

   int unsigned comparaciones;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function bit [31:0] leer_esperado(bit [7:0] addr);
      case (addr)
         CTRL_ADDR:    return {31'h0, en};        // CLR es autoclear: siempre 0
         SCRATCH_ADDR: return scratch;
         ACC_ADDR:     return acc;
         default:      return {30'h0, ovf, en};   // STATUS
      endcase
   endfunction : leer_esperado

   function void aplicar_escritura(apb_transaction t);
      bit [32:0] suma;
      case (t.addr)
         CTRL_ADDR: begin
            en = t.wdata[0];
            if (t.wdata[1]) begin  // CLR
               acc = 32'h0;
               ovf = 1'b0;
            end
         end
         SCRATCH_ADDR: begin
            scratch = t.wdata;
            if (en) begin  // el acumulador solo corre con EN=1
               suma = {1'b0, acc} + {1'b0, t.wdata};
               acc  = suma[31:0];
               if (suma[32]) ovf = 1'b1;  // pegajoso
            end
         end
         default: ;  // ACC y STATUS son de solo lectura: la escritura se ignora
      endcase
   endfunction : aplicar_escritura

   function void write(apb_transaction t);
      bit [31:0] esperado;
      comparaciones++;

      // Fuera del mapa: PSLVERR, PRDATA en cero, y el DUT no cambia de estado.
      if (t.addr >= MAPA_FIN) begin : sin_mapear
         if (!t.slverr)
            `uvm_error("SCOREBOARD", {"FAIL: falta PSLVERR fuera del mapa: ", t.convert2string()})
         else if (!t.write && t.rdata !== 32'h0)
            `uvm_error("SCOREBOARD", {"FAIL: PRDATA deberia ser 0: ", t.convert2string()})
         return;
      end : sin_mapear

      // Adentro del mapa nunca hay error, ni siquiera escribiendo un RO.
      if (t.slverr) begin : error_de_mas
         `uvm_error("SCOREBOARD", {"FAIL: PSLVERR en una direccion mapeada: ", t.convert2string()})
         return;
      end : error_de_mas

      if (t.write) aplicar_escritura(t);
      else begin : lectura
         esperado = leer_esperado(t.addr);
         if (t.rdata !== esperado)
            `uvm_error("SCOREBOARD", $sformatf("FAIL: %s  esperaba 0x%08h", t.convert2string(),
                                               esperado))
         else
            `uvm_info("SCOREBOARD", {"PASS: ", t.convert2string()}, UVM_HIGH)
      end : lectura
   endfunction : write

   function void report_phase(uvm_phase phase);
      `uvm_info("SCOREBOARD", $sformatf("%0d transferencias chequeadas", comparaciones), UVM_LOW)
   endfunction : report_phase

endclass : apb_scoreboard
