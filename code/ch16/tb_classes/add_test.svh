class add_test extends random_test;
   `uvm_component_utils(add_test);

   
   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      random_tester::type_id::set_type_override(add_tester::get_type());
      super.build_phase(phase);
   endfunction : build_phase
  
endclass
   