class testbench;

   // virtual: the object-world equivalent of a module's port list. It tells
   // the compiler that this variable is going to receive a handle to an
   // interface at some point in the future. See the slide in unit 10.
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

      // One thread per object. join_none: execute() returns and the three go on.
      fork
         tester_h.execute();
         coverage_h.execute();
         scoreboard_h.execute();
      join_none
   endtask : execute
endclass : testbench
