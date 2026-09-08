// El dual_test de la unidad 22, sin el run_phase: la estructura es identica y
// lo unico que cambia entre un test y otro es el ESTIMULO.
//
// Abstracta: nadie corre +UVM_TESTNAME=base_test. uvm_component_abstract_utils
// la registra en la factory sin generar el create() que no se podria llamar.
virtual class base_test extends uvm_test;
   `uvm_component_abstract_utils(base_test)

   env       env_h;
   sequencer sequencer_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      virtual vtalu_bfm clase_bfm, modulo_bfm;
      env_config env_config_h;

      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "clase_bfm", clase_bfm))
         `uvm_fatal("BASE TEST", "Failed to get clase_bfm")
      if (!uvm_config_db#(virtual vtalu_bfm)::get(this, "", "modulo_bfm", modulo_bfm))
         `uvm_fatal("BASE TEST", "Failed to get modulo_bfm")

      env_config_h = new(.clase_bfm(clase_bfm), .modulo_bfm(modulo_bfm));
      uvm_config_db#(env_config)::set(this, "env_h*", "config", env_config_h);

      env_h = env::type_id::create("env_h", this);
   endfunction : build_phase

   // El sequencer recien existe cuando el arbol termino de construirse. Y si,
   // esta linea atraviesa la jerarquia: es lo que el default_sequence evita.
   function void end_of_elaboration_phase(uvm_phase phase);
      sequencer_h = env_h.clase_agent_h.sequencer_h;
      if ($test$plusargs("TOPOLOGY")) uvm_root::get().print_topology();
   endfunction : end_of_elaboration_phase

endclass : base_test
