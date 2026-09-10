// Solution to the day 5 exercise -- Measure your dist.
//
// A single character apart from the file above: ":=" becomes ":/".
//
//   :=  the weight goes to EVERY value of the range. The middle is 254 values of weight 80,
//       that is 20320 against 10 and 10 at the edges: 00 comes up 0,05% of the time.
//   :/  the weight belongs to the WHOLE RANGE. 10 - 80 - 10 out of 100: 10%, 80%, 10%.
//
// Both compile, both run, and one of the two never fills the corner bins.
// That is the whole lesson.
package histograma_pkg;

   localparam int N = 4000;

   class operando;
      rand byte unsigned A;

      constraint peso {
         A dist {
            8'h00           :/ 10,
            [8'h01 : 8'hFE] :/ 80,
            8'hFF           :/ 10
         };
      }
   endclass

endpackage : histograma_pkg
