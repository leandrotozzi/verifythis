// Constrained Random 1 -- dist: ":=" y ":/" NO reparten igual.
//
// El curso pide en su plan de verificacion "entradas todas en 0 y todas en 1".
// Si el sesgo no existe, esos bins no se llenan y la cobertura se clava. Este
// ejemplo mide el sesgo de las dos escrituras en vez de creerle a la intuicion.
module top_dist;

   // El peso va a CADA valor del rango: el medio se lleva 254 de 256.
   class por_valor;
      rand byte unsigned A;
      constraint data {A dist {8'h00 := 1, [8'h01 : 8'hFE] := 1, 8'hFF := 1};}
   endclass

   // El peso se REPARTE dentro del rango: 1/4 en 00, 1/2 en el medio, 1/4 en FF.
   // Es el mismo sesgo que el get_data() de la seccion Cobertura funcional hacia a mano.
   class por_rango;
      rand byte unsigned A;
      constraint data {A dist {8'h00 :/ 1, [8'h01 : 8'hFE] :/ 2, 8'hFF :/ 1};}
   endclass

   localparam int N = 400;

   initial begin
      por_valor v;
      por_rango r;
      int v00, vff, r00, rff;

      v = new();
      r = new();

      repeat (N) begin
         if (!v.randomize()) $fatal(1, "randomize() de por_valor fallo");
         if (v.A == 8'h00) v00 = v00 + 1;
         if (v.A == 8'hFF) vff = vff + 1;

         if (!r.randomize()) $fatal(1, "randomize() de por_rango fallo");
         if (r.A == 8'h00) r00 = r00 + 1;
         if (r.A == 8'hFF) rff = rff + 1;
      end

      $display("%0d randomizaciones de cada version", N);
      $display("  :=   A=00 %5.1f%%   A=FF %5.1f%%   el peso va a cada valor",
               100.0 * v00 / N, 100.0 * vff / N);
      $display("  :/   A=00 %5.1f%%   A=FF %5.1f%%   el peso se reparte",
               100.0 * r00 / N, 100.0 * rff / N);
      $finish;
   end

endmodule : top_dist
