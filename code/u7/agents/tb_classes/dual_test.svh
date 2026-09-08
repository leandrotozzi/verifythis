class dual_test extends uvm_test;
   `uvm_component_utils(dual_test);

   env env_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      virtual vtalu_bfm clase_bfm, modulo_bfm;
      env_config env_config_h;

      // El top dejo las dos interfaces sueltas; el test las empaqueta.
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "clase_bfm", clase_bfm))
         `uvm_fatal("DUAL TEST", "Failed to get clase_bfm")
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "modulo_bfm", modulo_bfm))
         `uvm_fatal("DUAL TEST", "Failed to get modulo_bfm")

      env_config_h = new(.clase_bfm(clase_bfm), .modulo_bfm(modulo_bfm));
      uvm_config_db#(env_config)::set(this, "env_h*", "config", env_config_h);

      env_h = env::type_id::create("env_h", this);
   endfunction : build_phase

   // +TOPOLOGY imprime el arbol de componentes. Es la forma de VER que el
   // agent pasivo no construyo ni sequencer ni driver.
   function void end_of_elaboration_phase(uvm_phase phase);
      if ($test$plusargs("TOPOLOGY")) uvm_root::get().print_topology();
   endfunction : end_of_elaboration_phase

   task run_phase(uvm_phase phase);
      command_sequence seq;

      phase.raise_objection(this);

      // Lo unico que quedo cableado: el test atraviesa la jerarquia para
      // llegar al sequencer. La unidad 23 lo saca de aca.
      seq = command_sequence::type_id::create("seq");
      seq.start(env_h.clase_agent_h.sequencer_h);

      #500;
      phase.drop_objection(this);
   endtask : run_phase

endclass : dual_test
