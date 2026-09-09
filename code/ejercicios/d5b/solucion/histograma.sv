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
module top_histograma;

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

   localparam int N = 4000;

   initial begin
      operando o;
      int ceros, medio, unos;

      o = new();

      repeat (N) begin
         if (!o.randomize()) $fatal(1, "randomize() failed: the constraints do not close");
         case (o.A)
            8'h00:   ceros = ceros + 1;
            8'hFF:   unos  = unos + 1;
            default: medio = medio + 1;
         endcase
      end

      $display("%0d randomizaciones", N);
      $display("HISTOGRAM 00=%0.1f mid=%0.1f FF=%0.1f",
               100.0 * ceros / N, 100.0 * medio / N, 100.0 * unos / N);
      $finish;
   end

endmodule : top_histograma
