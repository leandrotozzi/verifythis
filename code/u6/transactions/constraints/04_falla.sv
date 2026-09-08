// Constrained Random 4 -- cuando randomize() devuelve 0, y como apagar cosas.
//
// randomize() no aborta ni imprime nada por su cuenta: devuelve 0 y sigue. Si
// nadie mira el valor de retorno, el testbench manda una transaction sin
// randomizar y el bug aparece tres componentes mas adelante.
module top_falla;

   class comando;
      rand byte unsigned A;
      constraint chico {A < 8'h10;}
      constraint grande {A > 8'hF0;}  // contradice a la anterior: no hay solucion
   endclass

   initial begin
      comando c;
      c = new();

      // 1. Las dos constraints activas: no hay ningun A que cumpla las dos.
      if (!c.randomize()) $display("1. randomize() devolvio 0: las constraints no cierran");
      else $display("1. randomize() dio %2h  (no deberia llegar aca)", c.A);

      // 2. constraint_mode(0) apaga una constraint en tiempo de ejecucion.
      c.grande.constraint_mode(0);
      if (!c.randomize()) $display("2. randomize() devolvio 0  (no deberia llegar aca)");
      else $display("2. con 'grande' apagada: A=%2h, y respeta 'chico'", c.A);

      // 3. rand_mode(0) saca al campo del sorteo: conserva su valor actual.
      c.A.rand_mode(0);
      if (!c.randomize()) $display("3. randomize() devolvio 0  (no deberia llegar aca)");
      else $display("3. con A fuera del sorteo: A=%2h, el mismo de antes", c.A);

      $finish;
   end

endmodule : top_falla
