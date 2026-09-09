class testbench;

   // 'virtual' is what makes an interface storable in a class: it is the
   // equivalent, in the world of objects, to the port list of a
   // module.
   // SV interface is a single compiled unit that delivers all the signals
   // The tester , scoreboard , and coverage modules got a copy of the
   // BFM through their module port list.

   // The virtual declaration tells the compiler that this variable will be given a
   // handle to an interface sometime in the future.
   virtual vtalu_bfm bfm;

   tester    tester_h;
   coverage  coverage_h;
   scoreboard scoreboard_h;

   function new(virtual vtalu_bfm b);
      bfm = b;
   endfunction : new

   // The objects have to be instantiated and their execute methods launched
   task execute();
      // Our 3 objects get instantiated and each gets a copy of the BFM
      // TODO(exercise 2): make tester_h be a mult_tester.
      // tester_h is of type tester; a mult_tester IS ALSO a tester.
      tester_h = new(bfm);
      coverage_h = new(bfm);
      scoreboard_h = new(bfm);

      // Three threads, one per object
      fork
         tester_h.execute();
         coverage_h.execute();
         scoreboard_h.execute();
      join_none
      // since join_none is used, this task finishes but the threads
      // keep running

   endtask : execute
endclass : testbench
