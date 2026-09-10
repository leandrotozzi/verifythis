// The checker of the day 2 exercise. It is not part of the course: it grades.
// Do not touch it -- run.sh checks its hash in intocables.sha before compiling.
//
// The exercise is polymorphism, and polymorphism is not visible in the log: a
// tester that always multiplies and a base get_op() rewritten to "return mul_op"
// print exactly the same thousand lines. So this class measures three things
// instead of reading one:
//
//   * WHAT WENT THROUGH THE BFM -- counted off the interface, not off a $display
//     of the file under test.
//   * WHAT THE BASE DRAW STILL PRODUCES -- get_op() on a plain tester has to go
//     on giving the eight operations. The exercise is to OVERRIDE it, not to
//     rewrite it.
//   * WHAT THE INSTALLED OBJECT ANSWERS THROUGH A BASE HANDLE -- which is the
//     lesson in one number. Through a `tester` handle it has to come out mul_op
//     every time, and that only happens if get_op() is virtual AND tester_h holds
//     a mult_tester.
//
// It extends tester because get_op() is protected: a derived class is the only
// one that can call it.
class chequeo extends tester;

   int muls  = 0;
   int others = 0;

   function new(virtual vtalu_bfm b);
      super.new(b);
   endfunction : new

   // How many DIFFERENT operations that tester answers through a base handle.
   // One bit per opcode, which is all the enum has.
   function int variety(tester t);
      bit [7:0] visto = '0;
      if (t == null) return 0;
      repeat (400) visto[t.get_op()] = 1'b1;
      return $countones(visto);
   endfunction : variety

   task mira();
      forever begin
         // One rising edge of start per operation the BFM puts on the bus.
         @(posedge bfm.start);
         if (bfm.op_set == mul_op) muls++;
         else begin
            others++;
            if (others == 1)
              $display("[CHEQUEO] a %s went by, and the test has to send multiplications only",
                       bfm.op_set.name());
         end
      end
   endtask : mira

endclass : chequeo
