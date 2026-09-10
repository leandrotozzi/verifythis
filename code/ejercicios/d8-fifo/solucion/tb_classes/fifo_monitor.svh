class fifo_monitor extends uvm_monitor;
   `uvm_component_utils(fifo_monitor)

   virtual fifo_if bfm;

   uvm_analysis_port #(fifo_transaction) ap_ciclo;
   uvm_analysis_port #(dato_transaction) ap_dato;

   int unsigned vistos;  // cycles with activity: monitor_test looks at it

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      fifo_agent_config cfg;
      if (!uvm_config_db#(fifo_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("MONITOR", "Failed to get agent config")
      bfm = cfg.bfm;
      bfm.monitor_h = this;
      ap_ciclo = new("ap_ciclo", this);
      ap_dato  = new("ap_dato", this);
   endfunction : build_phase

   // The interface calls it on every rising edge.
   function void write_ciclo(bit wr_en, bit [7:0] wr_data, bit rd_en,
                             bit full, bit almost_full, bit empty, bit almost_empty,
                             bit [3:0] count);
      fifo_transaction t;
      t = fifo_transaction::type_id::create("t");
      t.wr_en = wr_en;
      t.wr_data = wr_data;
      t.rd_en = rd_en;
      t.full = full;
      t.almost_full = almost_full;
      t.empty = empty;
      t.almost_empty = almost_empty;
      t.count = count;
      // A cycle with neither wr_en nor rd_en is not a transaction: it is the FIFO idle.
      // Publishing it anyway would fill the log and the scoreboard with nothing -- but it IS
      // published, because the flags have to be checked even when nothing is asked for.
      if (wr_en || rd_en) begin
         vistos++;
         `uvm_info("MONITOR", t.convert2string(), UVM_MEDIUM)
      end
      ap_ciclo.write(t);
   endfunction : write_ciclo

   function void write_dato(bit [7:0] dato);
      dato_transaction d;
      d = dato_transaction::type_id::create("d");
      d.dato = dato;
      `uvm_info("MONITOR", d.convert2string(), UVM_HIGH)
      ap_dato.write(d);
   endfunction : write_dato

endclass : fifo_monitor
