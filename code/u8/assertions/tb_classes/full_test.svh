// Mismo estimulo que el dual_test de la unidad 22, ahora en tres sequences.
class full_test extends base_test;
   `uvm_component_utils(full_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      full_sequence full_seq;
      full_seq = full_sequence::type_id::create("full_seq");

      // El objection lo levanta EL TEST, no la sequence: la sequence no sabe
      // nada de fases, y tiene que poder correr adentro de otra sequence.
      phase.raise_objection(this);
      full_seq.start(sequencer_h);   // no vuelve hasta que body() termino
      phase.drop_objection(this);
   endtask : run_phase

endclass : full_test
