// The argument for RAL that survives a code review: tests you did not write.
//
// Both sequences below ship with uvm-core. They read the register model -- the
// addresses, the field positions, the access strings -- and generate the
// stimulus and the checks from it. Nothing here is specific to this DUT.
//
//   uvm_reg_hw_reset_seq   reads every register after reset and compares it
//                          against the reset value declared in configure()
//   uvm_reg_bit_bash_seq   writes and reads back every writable bit of every
//                          register, one at a time, in both directions
//
// Run it with +MAL and the register model declares CTRL.CLR as "RW" instead of
// "WOC" -- one wrong word in one string. bit_bash catches it without anyone
// writing a test for CTRL.
class builtin_test extends ral_base_test;
   `uvm_component_utils(builtin_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      uvm_reg_hw_reset_seq rst_seq;
      uvm_reg_bit_bash_seq bash_seq;

      phase.raise_objection(this);
      reset_model();

      rst_seq = uvm_reg_hw_reset_seq::type_id::create("rst_seq");
      rst_seq.model = model;
      rst_seq.start(null);

      bash_seq = uvm_reg_bit_bash_seq::type_id::create("bash_seq");
      bash_seq.model = model;
      bash_seq.start(null);

      phase.drop_objection(this);
   endtask : run_phase

endclass : builtin_test
