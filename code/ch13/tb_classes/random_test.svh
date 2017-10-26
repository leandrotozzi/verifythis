class random_test extends uvm_test;
   `uvm_component_utils(random_test);

   env       env_h;

   function void build_phase(uvm_phase phase);
      base_tester::type_id::set_type_override(random_tester::get_type());
      env_h = env::type_id::create("env_h",this);
   endfunction : build_phase
   
   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new
   
endclass