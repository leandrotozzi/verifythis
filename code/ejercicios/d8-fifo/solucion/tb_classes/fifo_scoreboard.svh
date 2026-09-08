// El scoreboard de la FIFO. Y aca esta la diferencia con el capstone del APB,
// que es el motivo entero de este ejercicio:
//
//   el del APB podia ser una TABLA -- cuatro registros, una direccion, un
//   valor. Este no. Una FIFO no tiene direcciones: tiene ORDEN y tiene
//   OCUPACION, y las dos son estado que hay que llevar.
//
// El modelo de referencia son dos colas:
//   modelo[$]    lo que la FIFO deberia tener adentro, en orden
//   esperado[$]  lo que ya salio del modelo y todavia no aparecio por rd_data
//
// Y hay dos chequeos, no uno: las BANDERAS en cada ciclo, y los DATOS cuando
// salen. Un scoreboard que solo compara datos pasa en verde con +BUG=1.
`uvm_analysis_imp_decl(_ciclo)
`uvm_analysis_imp_decl(_dato)

class fifo_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(fifo_scoreboard)

   uvm_analysis_imp_ciclo #(fifo_transaction, fifo_scoreboard) imp_ciclo;
   uvm_analysis_imp_dato #(dato_transaction, fifo_scoreboard) imp_dato;

   protected bit [7:0] modelo[$];
   protected bit [7:0] esperado[$];

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      imp_ciclo = new("imp_ciclo", this);
      imp_dato  = new("imp_dato", this);
   endfunction : build_phase

   protected function void comparar_bandera(string nombre, bit vista, bit predicha, int n);
      if (vista !== predicha)
         `uvm_error("SCOREBOARD", $sformatf(
                    "%s: el DUT dice %0b y con %0d adentro tendria que decir %0b",
                    nombre, vista, n, predicha))
   endfunction : comparar_bandera

   function void write_ciclo(fifo_transaction t);
      int n = modelo.size();
      bit saca, mete;

      // 1. Las banderas describen el estado ANTES del flanco, asi que se
      //    chequean contra el modelo antes de aplicar nada.
      comparar_bandera("full", t.full, (n == DEPTH), n);
      comparar_bandera("empty", t.empty, (n == 0), n);
      comparar_bandera("almost_full", t.almost_full, (n >= AF), n);
      comparar_bandera("almost_empty", t.almost_empty, (n <= AE), n);
      if (t.count !== 4'(n))
         `uvm_error("SCOREBOARD", $sformatf("count: el DUT dice %0d y el modelo tiene %0d",
                                            t.count, n))

      // 2. Y ahora el ciclo. El orden importa y es la letra chica de la spec:
      //    la lectura libera el lugar en el MISMO ciclo, asi que una escritura
      //    simultanea entra aunque este llena. Al reves no: leer de una FIFO
      //    vacia no saca el dato que entra en ese ciclo.
      saca = t.rd_en && (n > 0);
      mete = t.wr_en && ((n < DEPTH) || saca);

      if (saca) esperado.push_back(modelo.pop_front());
      if (mete) modelo.push_back(t.wr_data);

      // La escritura descartada NO es un error del DUT: la spec dice que se
      // ignora en silencio. Se deja anotada, que es lo unico honesto.
      if (t.wr_en && !mete)
         `uvm_info("SCOREBOARD", $sformatf("escritura de %2h descartada: la FIFO estaba llena",
                                           t.wr_data), UVM_MEDIUM)
   endfunction : write_ciclo

   function void write_dato(dato_transaction d);
      bit [7:0] exp;
      if (esperado.size() == 0) begin
         `uvm_error("SCOREBOARD", $sformatf("salio %2h y el modelo no pidio nada", d.dato))
         return;
      end
      exp = esperado.pop_front();
      if (d.dato !== exp)
         `uvm_error("SCOREBOARD", $sformatf("salio %2h y esperaba %2h", d.dato, exp))
      else `uvm_info("SCOREBOARD", $sformatf("OK %2h", d.dato), UVM_HIGH)
   endfunction : write_dato

   // El chequeo que se olvida siempre, y es la mitad del valor: lo que quedo
   // en la cola son lecturas que el DUT nunca contesto.
   function void check_phase(uvm_phase phase);
      if (esperado.size() != 0)
         `uvm_error("SCOREBOARD", $sformatf(
                    "quedaron %0d datos leidos que nunca salieron por rd_data",
                    esperado.size()))
   endfunction : check_phase

endclass : fifo_scoreboard
