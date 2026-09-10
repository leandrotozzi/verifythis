// The checker of the day 5 exercise. It is not part of the exercise: it draws
// the N values out of YOUR operando, counts them in three buckets and prints
// the HISTOGRAM line run.sh reads.
//
// Do not touch it. run.sh checks its hash in intocables.sha before compiling,
// because the whole exercise is the constraint in histograma.sv and rewriting
// this $display would "pass" it without measuring a thing.
module top_histograma;
   import histograma_pkg::*;

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

      $display("%0d randomizations", N);
      $display("HISTOGRAM 00=%0.1f mid=%0.1f FF=%0.1f",
               100.0 * ceros / N, 100.0 * medio / N, 100.0 * unos / N);
      $finish;
   end

endmodule : top_histograma
