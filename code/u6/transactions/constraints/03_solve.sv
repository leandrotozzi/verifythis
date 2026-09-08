// Constrained Random 3 -- el orden de resolucion sesga sin avisar.
//
// La constraint de abajo parece inofensiva y es la trampa clasica: el solver
// elige uniformemente entre las SOLUCIONES, no entre los valores de cada campo.
// Con es_reset=1 hay una sola solucion (A=00); con es_reset=0 hay 256.
// Resultado: el reset se pide 1 de cada 257 veces, y el bin "cualquier
// operacion despues de un reset" del plan de la seccion Cobertura funcional no se llena nunca.
module top_solve;

   class sesgada;
      rand bit           es_reset;
      rand byte unsigned A;
      constraint c {es_reset -> A == 8'h00;}
   endclass

   // La respuesta del lenguaje es "solve es_reset before A": elegi el campo de
   // control PRIMERO y despues resolve el resto. Verilator 5.052 acepta la
   // sintaxis y NO la respeta -- deja es_reset clavado en 0, que es peor que
   // ignorarla. Repro en code/verilator/repro-solve-before.sv.
   //
   // El rodeo que si es portable: pedir explicitamente el reparto del campo de
   // control. Dice lo mismo y no depende de que el solver ordene bien.
   class pareja extends sesgada;
      constraint reparto {es_reset dist {1'b0 :/ 1, 1'b1 :/ 1};}
   endclass

   localparam int N = 2000;

   initial begin
      sesgada s;
      pareja  p;
      int s_reset, p_reset;

      s = new();
      p = new();

      repeat (N) begin
         if (!s.randomize()) $fatal(1, "randomize() de sesgada fallo");
         if (s.es_reset) s_reset = s_reset + 1;

         if (!p.randomize()) $fatal(1, "randomize() de pareja fallo");
         if (p.es_reset) p_reset = p_reset + 1;
      end

      $display("%0d randomizaciones de cada version", N);
      $display("  tal cual              es_reset=1 en %5.1f%%   (1 de cada 257)",
               100.0 * s_reset / N);
      $display("  con dist en es_reset  es_reset=1 en %5.1f%%", 100.0 * p_reset / N);
      $finish;
   end

endmodule : top_solve
