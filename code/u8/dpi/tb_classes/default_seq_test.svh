// El mismo estimulo que full_test, SIN run_phase: la sequence la arranca el
// propio sequencer al empezar la fase.
class default_seq_test extends base_test;
   `uvm_component_utils(default_seq_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      full_sequence full_seq;

      // super.build_phase() de base_test, que es una clase NUESTRA: arma el
      // env. Lo que el curso nunca llama es el build_phase de uvm_component.
      super.build_phase(phase);

      full_seq = full_sequence::type_id::create("full_seq");
      full_seq.count = 200;

      // SIN esta linea la main_phase termina en t=0: nadie levanta el objection,
      // y una fase sin objection dura cero. El test PASA sin mandar estimulo.
      full_seq.set_automatic_phase_objection(1);

      // El nombre de instancia lleva el sufijo "_phase": es la fase en la que el
      // sequencer va a arrancarla. Fijate que el test ya no nombra al sequencer
      // como handle: lo nombra como RUTA, y eso es una config, no codigo.
      uvm_config_db#(uvm_sequence_base)::set(
          this, "env_h.clase_agent_h.sequencer_h.main_phase", "default_sequence",
          full_seq);
   endfunction : build_phase

endclass : default_seq_test
