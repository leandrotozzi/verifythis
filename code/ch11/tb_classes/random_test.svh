// Diagrama de Clases
// ----------------------------------------------------------
// random_test extiende una clase llamada uvm_test
// La clase uvm_test extiende a su vez, una clase llamada uvm_component
// por lo tanto, random_test es una extension de uvm_component

class random_test extends uvm_test;
    // 1) Registramos la clase a la factory mediante la macro:
    // 'uvm_component_utils 
    // Esto va a permitir al factory crear elementos random_test
   `uvm_component_utils(random_test);

 virtual tinyalu_bfm bfm;
   
   // 2) Constructor
   // Para poder extender uvm_component, necesitamos seguir ciertas reglas 
   // respecto del constructor new()
   //    * El constructor debe tener 2 argumentos: name y parent
   //       definidos en ese orden
   //    * name es del tipo string y parent debe ser del tipo uvm_component
   //    * La 1er linea del constructor debe ser super.new(name, parent)

   function new (string name, uvm_component parent);
      super.new(name,parent);

      // Una vez que cumplimos con esas reglas, podemos hacer cualquier cosa
      // con nuestro constructor
      if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
        $fatal("Failed to get BFM");
   endfunction : new

  // 3) Run Phase Method Override
  // En la version modular, llamabamos a los metodos explicitamente tb.execute()
  // Cuando llamamos a run_test() en el modulo top, UVM crea un objeto test usando 
  // la factory y luego llama al metodo run_phase del objeto
  // Esta task run_phase debe tener un unico argumento del tipo uvm_phase
   task run_phase(uvm_phase phase);
      random_tester    random_tester_h;
      coverage  coverage_h;
      scoreboard scoreboard_h;

      // 4) Como sabemos cuando termina? Objections!
      // raise_objection y drop_objection permiten saber cuando termina la ejecucion 
      // El test lo arrancamos llamando al metodo run_test()
      // Si levantamos una objection, el test no nos puede apagar
      // Debemos lanzar la objection antes de mandar los estimulos
      phase.raise_objection(this);

      random_tester_h    = new(bfm);
      coverage_h   = new(bfm);
      scoreboard_h = new(bfm);
      
      fork
         coverage_h.execute();
         scoreboard_h.execute();
      join_none

      random_tester_h.execute();

      // Cuando random_tester_h.execute() termina, levantamos la objection 
      // y el test se da por terminado
      phase.drop_objection(this);

   endtask : run_phase

endclass