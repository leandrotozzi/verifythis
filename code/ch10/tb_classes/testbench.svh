class testbench;

   // virtual WTF???: 
   //    object world's equivalent of a module's port list.
   // SV interface is a single compiled unit that delivers all the signals
   // The tester , scoreboard , and coverage modules got a copy of the 
   // BFM through their module port list.

   // The virtual declaration tells the compiler that this variable will be given a
   // handle to an interface sometime in the future.
   virtual tinyalu_bfm bfm;

   tester    tester_h;
   coverage  coverage_h;
   scoreboard scoreboard_h;
   
   function new (virtual tinyalu_bfm b);
       bfm = b;
   endfunction : new

   // Necesitamos instanciar los objetos y lanzar sus metodos de ejecucion
   task execute();
      // Instanciamos nuestros 3 objetos y les pasamos una copia de la BFM
      tester_h     = new(bfm);
      coverage_h   = new(bfm);
      scoreboard_h = new(bfm);

      // Creamos 3 threads, uno por cada objeto
      fork
         tester_h.execute();
         coverage_h.execute();
         scoreboard_h.execute();
      join_none
      // como usamos join_none, esta tarea termina pero sigue la ejecucion
      // de los threads

   endtask : execute
endclass : testbench