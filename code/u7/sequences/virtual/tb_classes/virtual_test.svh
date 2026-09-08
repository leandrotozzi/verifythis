// El test no cambia de forma: crea una sequence y la arranca. Lo unico distinto
// es SOBRE QUE la arranca -- el sequencer virtual, no el del agent.
class virtual_test extends base_test;
   `uvm_component_utils(virtual_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      coordinada_sequence seq;
      seq = coordinada_sequence::type_id::create("seq");

      phase.raise_objection(this);
      seq.start(env_h.virtual_sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase

endclass : virtual_test
