// The same add_test as the Transactions section, word for word. No sequence finds
// out: random_sequence still asks the factory for a command_transaction,
// and the factory hands it back an add_transaction.
class add_test extends full_test;
   `uvm_component_utils(add_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      command_transaction::type_id::set_type_override(add_transaction::get_type());
      super.build_phase(phase);
   endfunction : build_phase

endclass : add_test
