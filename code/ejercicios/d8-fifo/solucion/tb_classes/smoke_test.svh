// Etapa 2: el driver maneja la FIFO, con estimulo dirigido.
class smoke_test extends base_test;
   `uvm_component_utils(smoke_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      smoke_sequence seq;
      seq = smoke_sequence::type_id::create("seq");
      phase.raise_objection(this);
      seq.start(sequencer_h);
      // El dato del ultimo ciclo sale UN flanco despues: sin este colchon, el
      // scoreboard se queda con una lectura sin contestar. Es el drain_time
      // del dia 3, escrito a mano.
      #100;
      phase.drop_objection(this);
   endtask : run_phase

endclass : smoke_test
