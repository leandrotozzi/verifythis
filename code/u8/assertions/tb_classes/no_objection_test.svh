// SOLO para la slide de la trampa: identico a default_seq_test menos la linea
// set_automatic_phase_objection(1). Corre, no reporta un solo error, sale con
// codigo 0 -- y termina en t=0 sin haber mandado un estimulo.
class no_objection_test extends base_test;
   `uvm_component_utils(no_objection_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      full_sequence full_seq;
      super.build_phase(phase);

      full_seq = full_sequence::type_id::create("full_seq");
      full_seq.count = 200;
      // Falta a proposito: full_seq.set_automatic_phase_objection(1);
      uvm_config_db#(uvm_sequence_base)::set(
          this, "env_h.clase_agent_h.sequencer_h.main_phase", "default_sequence",
          full_seq);
   endfunction : build_phase

endclass : no_objection_test
