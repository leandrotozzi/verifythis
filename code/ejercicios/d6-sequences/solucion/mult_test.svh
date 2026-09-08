class mult_test extends base_test;
   `uvm_component_utils(mult_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      mult_sequence mult_seq;
      mult_seq = mult_sequence::type_id::create("mult_seq");

      phase.raise_objection(this);
      mult_seq.start(sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase

endclass : mult_test
