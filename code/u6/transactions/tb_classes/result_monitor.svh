class result_monitor extends uvm_component;
   `uvm_component_utils(result_monitor);

   virtual vtalu_bfm bfm;
   uvm_analysis_port #(result_transaction) ap;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("RESULT MONITOR", "Failed to get BFM")

      bfm.result_monitor_h = this;
      ap = new("ap", this);
   endfunction : build_phase

   // Aca cambiamos a transactions
   function void write_to_monitor(shortint r, bit o);
      result_transaction result_t;
      // Por la factory, como el command_transaction del tester: es el punto
      // por donde el resultado entra al TB, asi que es el que hay que poder
      // overridear.
      result_t = result_transaction::type_id::create("result_t");
      result_t.result = r;
      result_t.ovf    = o;
      ap.write(result_t);
   endfunction : write_to_monitor

endclass : result_monitor

