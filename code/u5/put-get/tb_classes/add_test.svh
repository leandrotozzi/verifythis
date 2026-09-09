class add_test extends random_test;
   `uvm_component_utils(add_test);

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      // The override goes FIRST, and super.build_phase() -- the one that creates
      // the env -- goes after it. Without the super the env never gets built and
      // the test runs an empty tree: it ends at t=0 and says PASS.
      random_tester::type_id::set_type_override(add_tester::get_type());
      super.build_phase(phase);
   endfunction : build_phase

endclass
