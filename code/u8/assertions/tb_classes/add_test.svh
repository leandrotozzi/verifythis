// El mismo add_test de la seccion Transactions, palabra por palabra. Ninguna sequence se
// entera: random_sequence sigue pidiendole un command_transaction a la factory,
// y la factory le devuelve un add_transaction.
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
