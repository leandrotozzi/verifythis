// Day 5 exercise -- Measure your dist.
//
// What is asked: that the 10000 randomizations give 10% at 00, 10% at FF and
// 80% in the middle, with a tolerance of +-2 points per bucket.
//
// The class below ALREADY has the weights 10, 80 and 10 written down. Run the
// example before touching anything and compare what comes out with this line.
//
//   bash run.sh
//
// The only thing to change is inside the constraint.
module top_histograma;

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

   localparam int N = 4000;

   // The histogram in three buckets. This is not to be touched: it is what the
   // checker reads, and it is the part of the exercise that is already done.
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
