class command_monitor extends uvm_component;
   `uvm_component_utils(command_monitor);

   virtual vtalu_bfm bfm;

   uvm_analysis_port #(command_transaction) ap;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
         `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
      bfm.command_monitor_h = this;
      ap = new("ap", this);
   endfunction : build_phase

   // Aca cambiamos a transactions
   function void write_to_monitor(byte A, byte B, operation_t op);
      command_transaction cmd;
      `uvm_info("COMMAND MONITOR", $sformatf(
                "MONITOR: A: %2h  B: %2h  op: %s", A, B, op.name()), UVM_HIGH);
      // Por la factory, igual que el result_monitor: el monitor es la puerta por
      // la que el comando entra al TB, asi que su tipo tiene que ser overrideable.
      cmd = command_transaction::type_id::create("cmd");
      cmd.A = B;
      cmd.B = B;
      cmd.op = op;
      ap.write(cmd);
   endfunction : write_to_monitor
endclass : command_monitor
