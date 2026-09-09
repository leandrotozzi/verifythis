// Constrained Random 1 -- dist: ":=" and ":/" do NOT hand out the same way.
//
// The verification plan of the course asks for "inputs all 0s and all 1s".
// Without the bias those bins never fill and the coverage stalls. This example
// measures the bias of both spellings instead of trusting intuition.
module top_dist;

   // cb: both-spellings
   // The weight goes to EVERY value of the range: the middle takes 254 of 256.
   class por_valor;
      rand byte unsigned A;
      constraint data {A dist {8'h00 := 1, [8'h01 : 8'hFE] := 1, 8'hFF := 1};}
   endclass

   // The weight is SPLIT inside the range: 1/4 at 00, 1/2 in the middle, 1/4 at FF.
   // It is the same bias get_data() of the Functional coverage section did by hand.
   class por_rango;
      rand byte unsigned A;
      constraint data {A dist {8'h00 :/ 1, [8'h01 : 8'hFE] :/ 2, 8'hFF :/ 1};}
   endclass
   // cb: end

   localparam int N = 400;

   initial begin
      por_valor v;
      por_rango r;
      int v00, vff, r00, rff;

      v = new();
      r = new();

      repeat (N) begin
         if (!v.randomize()) $fatal(1, "por_valor randomize() failed");
         if (v.A == 8'h00) v00 = v00 + 1;
         if (v.A == 8'hFF) vff = vff + 1;

         if (!r.randomize()) $fatal(1, "por_rango randomize() failed");
         if (r.A == 8'h00) r00 = r00 + 1;
         if (r.A == 8'hFF) rff = rff + 1;
      end

      $display("%0d randomizations of each version", N);
      $display("  :=   A=00 %5.1f%%   A=FF %5.1f%%   the weight goes to each value",
               100.0 * v00 / N, 100.0 * vff / N);
      $display("  :/   A=00 %5.1f%%   A=FF %5.1f%%   the weight gets split",
               100.0 * r00 / N, 100.0 * rff / N);
      $finish;
   end

endmodule : top_dist
