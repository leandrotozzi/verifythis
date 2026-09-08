class vtalu_agent extends uvm_agent;
   `uvm_component_utils(vtalu_agent)

   vtalu_agent_config cfg;

   sequencer       sequencer_h;
   driver          driver_h;
   command_monitor command_monitor_h;
   result_monitor  result_monitor_h;

   uvm_analysis_port #(command_transaction) command_ap;
   uvm_analysis_port #(result_transaction)  result_ap;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(vtalu_agent_config)::get(this, "", "config", cfg))
         `uvm_fatal("AGENT", "Failed to get agent config")
      is_active = cfg.get_is_active();

      // TODO(ejercicio 6): estas dos lineas tienen que correr SOLO si el agent
      // es activo. Hoy corren siempre, asi que is_active no sirve para nada.
      // Mira get_is_active().
      sequencer_h = sequencer::type_id::create("sequencer_h", this);
      driver_h    = driver::type_id::create("driver_h", this);

      // Los monitores y los dos analysis ports, en cambio, van SIEMPRE.
      command_monitor_h = command_monitor::type_id::create("command_monitor_h", this);
      result_monitor_h  = result_monitor::type_id::create("result_monitor_h", this);

      command_ap = new("command_ap", this);
      result_ap  = new("result_ap", this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      // TODO(ejercicio 6): esta conexion tambien es solo del agent activo. Un
      // agent pasivo no tiene driver ni sequencer, asi que esta linea le busca
      // un puerto a un null.
      driver_h.seq_item_port.connect(sequencer_h.seq_item_export);

      command_monitor_h.ap.connect(command_ap);
      result_monitor_h.ap.connect(result_ap);
   endfunction : connect_phase

endclass : vtalu_agent
