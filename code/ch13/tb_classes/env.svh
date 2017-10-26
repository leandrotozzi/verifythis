// Esta clase define la estructura del TB
// Instancia los objetos en el TB
class env extends uvm_env;
   `uvm_component_utils(env);

   base_tester   tester_h;
   coverage      coverage_h;
   scoreboard    scoreboard_h;

   function void build_phase(uvm_phase phase);
      // tester_h crea un objeto de la clase base_tester
      // Sabemos que base_tester es una virtual class, por lo tanto
      // no podemos crear un un objeto base_tester, debemos crear un clase heredada
      // de base_tester. Entonces porque funciona este codigo?
      // env class esta usando la variable base_tester como un placeholder
      tester_h     = base_tester::type_id::create("tester_h",this);
      coverage_h   = coverage::type_id::create ("coverage_h",this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
   endfunction : build_phase

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass