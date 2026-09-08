class testbench;

   // virtual: el equivalente en objetos de la port list de un modulo. Le dice
   // al compilador que esta variable va a recibir un handle a una interface
   // en algun momento futuro. Ver la slide de la unidad 10.
   virtual vtalu_bfm bfm;

   tester    tester_h;
   coverage  coverage_h;
   scoreboard scoreboard_h;

   function new(virtual vtalu_bfm b);
      bfm = b;
   endfunction : new

   task execute();
      tester_h = new(bfm);
      coverage_h = new(bfm);
      scoreboard_h = new(bfm);

      // Un thread por objeto. join_none: execute() vuelve y los tres siguen.
      fork
         tester_h.execute();
         coverage_h.execute();
         scoreboard_h.execute();
      join_none
   endtask : execute
endclass : testbench
