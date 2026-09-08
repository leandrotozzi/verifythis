// Solucion del ejercicio del dia 5 -- Medi tu dist.
//
// Un solo caracter de diferencia con el archivo de arriba: ":=" pasa a ":/".
//
//   :=  el peso va a CADA valor del rango. El medio son 254 valores de peso 80,
//       o sea 20320 contra 10 y 10 de los bordes: 00 sale el 0,05% de las veces.
//   :/  el peso es del RANGO ENTERO. 10 - 80 - 10 sobre 100: 10%, 80%, 10%.
//
// Los dos compilan, los dos corren, y uno de los dos no llena los bins de borde
// nunca. Esa es toda la leccion.
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
         if (!o.randomize()) $fatal(1, "randomize() fallo: las constraints no cierran");
         case (o.A)
            8'h00:   ceros = ceros + 1;
            8'hFF:   unos  = unos + 1;
            default: medio = medio + 1;
         endcase
      end

      $display("%0d randomizaciones", N);
      $display("HISTOGRAMA 00=%0.1f medio=%0.1f FF=%0.1f",
               100.0 * ceros / N, 100.0 * medio / N, 100.0 * unos / N);
      $finish;
   end

endmodule : top_histograma
