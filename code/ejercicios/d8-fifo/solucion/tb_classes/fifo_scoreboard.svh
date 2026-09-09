// The FIFO scoreboard. And here is the difference with the APB capstone,
// which is the whole reason for this exercise:
//
//   the APB one could be a TABLE -- four registers, one address, one
//   value. This one cannot. A FIFO has no addresses: it has ORDER and it has
//   OCCUPANCY, and both are state that has to be carried.
//
// The reference model is two queues:
//   modelo[$]    what the FIFO should have inside, in order
//   esperado[$]  what already left the model and has not shown up on rd_data yet
//
// And there are two checks, not one: the FLAGS on every cycle, and the DATA when
// they come out. A scoreboard that only compares data passes green with +BUG=1.
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
                    "%s: the DUT says %0b and with %0d inside it should say %0b",
                    nombre, vista, n, predicha))
   endfunction : comparar_bandera

   function void write_ciclo(fifo_transaction t);
      int n = modelo.size();
      bit saca, mete;

      // 1. The flags describe the state BEFORE the edge, so they get
      //    checked against the model before applying anything.
      comparar_bandera("full", t.full, (n == DEPTH), n);
      comparar_bandera("empty", t.empty, (n == 0), n);
      comparar_bandera("almost_full", t.almost_full, (n >= AF), n);
      comparar_bandera("almost_empty", t.almost_empty, (n <= AE), n);
      if (t.count !== 4'(n))
         `uvm_error("SCOREBOARD", $sformatf("count: the DUT says %0d and the model has %0d",
                                            t.count, n))

      // 2. And now the cycle. The order matters and it is the fine print of the spec:
      //    the read frees the place in the SAME cycle, so a simultaneous
      //    write goes in even when it is full. Not the other way round: reading from an empty
      //    FIFO does not take out the datum that goes in on that cycle.
      saca = t.rd_en && (n > 0);
      mete = t.wr_en && ((n < DEPTH) || saca);

      if (saca) esperado.push_back(modelo.pop_front());
      if (mete) modelo.push_back(t.wr_data);

      // The discarded write is NOT a DUT error: the spec says it gets
      // ignored silently. It gets noted down, which is the only honest thing.
      if (t.wr_en && !mete)
         `uvm_info("SCOREBOARD", $sformatf("write of %2h discarded: the FIFO was full",
                                           t.wr_data), UVM_MEDIUM)
   endfunction : write_ciclo

   function void write_dato(dato_transaction d);
      bit [7:0] exp;
      if (esperado.size() == 0) begin
         `uvm_error("SCOREBOARD", $sformatf("%2h came out and the model asked for nothing", d.dato))
         return;
      end
      exp = esperado.pop_front();
      if (d.dato !== exp)
         `uvm_error("SCOREBOARD", $sformatf("salio %2h y esperaba %2h", d.dato, exp))
      else `uvm_info("SCOREBOARD", $sformatf("OK %2h", d.dato), UVM_HIGH)
   endfunction : write_dato

   // The check everybody forgets, and it is half the value: what was left
   // in the queue are reads the DUT never answered.
   function void check_phase(uvm_phase phase);
      if (esperado.size() != 0)
         `uvm_error("SCOREBOARD", $sformatf(
                    "%0d read data were left that never came out on rd_data",
                    esperado.size()))
   endfunction : check_phase

endclass : fifo_scoreboard
