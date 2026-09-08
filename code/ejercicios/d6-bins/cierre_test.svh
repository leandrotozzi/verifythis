// El enunciado, ya escrito. No hace falta tocarlo.
//
// Arranca el estimulo en tres tramos, que es la forma de la unidad 23:
//
//   1. reset_sequence           el DUT arranca con reset_n en 0
//   2. random_sequence          el "grueso barato": COUNT operaciones al azar
//   3. cierre_sequence          la tuya: el caso dirigido que llena el bin
//
// +SIN_CIERRE saltea el tramo 3. Es como run.sh mide la cobertura ANTES de tu
// caso dirigido, para poder compararla con la de despues.
class cierre_test extends base_test;
   `uvm_component_utils(cierre_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      reset_sequence  reset_seq;
      random_sequence random_seq;
      cierre_sequence cierre_seq;
      int             count = 60;

      void'($value$plusargs("COUNT=%d", count));

      reset_seq  = reset_sequence::type_id::create("reset_seq");
      random_seq = random_sequence::type_id::create("random_seq");
      random_seq.count = count;

      phase.raise_objection(this);
      reset_seq.start(sequencer_h);
      random_seq.start(sequencer_h);

      if (!$test$plusargs("SIN_CIERRE")) begin
         cierre_seq = cierre_sequence::type_id::create("cierre_seq");
         cierre_seq.start(sequencer_h);
      end
      phase.drop_objection(this);
   endtask : run_phase

endclass : cierre_test
