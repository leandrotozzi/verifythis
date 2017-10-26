class random_test extends uvm_test;
   `uvm_component_utils(random_test);

   random_tester tester_h;
   coverage      coverage_h;
   scoreboard    scoreboard_h;

   // random_test extends uvm_test and uvm_test extends uvm_component 
   // por lo tanto, debemos usar build_phase para instanciar los componentes
   function void build_phase(uvm_phase phase);
      tester_h      = new("tester_h", this);
      coverage_h    = new("coverage_h",    this);
      scoreboard_h  = new("scoreboard_h",    this);
   endfunction : build_phase
   
   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

   // random_test no tiene un run_phase(), ya que su trabajo termina
   // cuando construye el test

endclass