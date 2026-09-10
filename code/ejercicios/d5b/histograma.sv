// Day 5 exercise -- Measure your dist.
//
// What is asked: that the 4000 randomizations give 10% at 00, 10% at FF and
// 80% in the middle, with a tolerance of +-2 points per bucket.
//
// The class below ALREADY has the weights 10, 80 and 10 written down. Run the
// example before touching anything and compare what comes out with this line.
//
//   bash run.sh
//
// The only thing to change is inside the constraint. Whoever draws the values
// and prints the histogram is histograma_top.sv, and that one you cannot touch:
// run.sh checks its hash before compiling.
package histograma_pkg;

   // The size of the sample. It is not part of what is asked, and the checker
   // reads it out of the run: with fewer draws the percentages stop meaning
   // anything, which is the opposite of the lesson.
   localparam int N = 4000;

   class operando;
      rand byte unsigned A;

      // <<< HERE >>>
      constraint peso {
         A dist {
            8'h00           := 10,
            [8'h01 : 8'hFE] := 80,
            8'hFF           := 10
         };
      }
   endclass

endpackage : histograma_pkg
