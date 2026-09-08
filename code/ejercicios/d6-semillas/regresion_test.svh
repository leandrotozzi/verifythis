// El enunciado, ya escrito. No hace falta tocarlo.
//
// Reset y COUNT operaciones al azar, nada mas. COUNT es chico a proposito: con
// 1000 el random satura lo que puede alcanzar y todas las semillas dan el mismo
// numero. Con 25 no llega, y ahi se ve lo que el ejercicio quiere mostrar.
class regresion_test extends base_test;
   `uvm_component_utils(regresion_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      reset_sequence  reset_seq;
      random_sequence random_seq;
      int             count = 25;

      void'($value$plusargs("COUNT=%d", count));

      reset_seq  = reset_sequence::type_id::create("reset_seq");
      random_seq = random_sequence::type_id::create("random_seq");
      random_seq.count = count;

      phase.raise_objection(this);
      reset_seq.start(sequencer_h);
      random_seq.start(sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase

endclass : regresion_test
