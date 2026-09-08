// Ejercicio del dia 5 -- Medi tu dist.
//
// Se pide: que las 10000 randomizaciones den 10% en 00, 10% en FF y 80% en el
// medio, con tolerancia de +-2 puntos en cada casillero.
//
// La clase de abajo YA tiene los pesos 10, 80 y 10 escritos. Corre el ejemplo
// antes de tocar nada y compara lo que sale con lo que dice esta linea.
//
//   bash run.sh
//
// Lo unico que hay que cambiar esta adentro de la constraint.
module top_histograma;

   class operando;
      rand byte unsigned A;

      // <<< ACA >>>
      constraint peso {
         A dist {
            8'h00           := 10,
            [8'h01 : 8'hFE] := 80,
            8'hFF           := 10
         };
      }
   endclass

   localparam int N = 4000;

   // El histograma en tres casilleros. Esto no se toca: es lo que lee el
   // corrector, y es la parte del ejercicio que ya esta hecha.
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
