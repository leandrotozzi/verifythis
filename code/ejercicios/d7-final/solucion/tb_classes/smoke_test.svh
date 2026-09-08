// Etapa 2: el driver maneja el bus, con estimulo dirigido.
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
      phase.drop_objection(this);
   endtask : run_phase

endclass : smoke_test
