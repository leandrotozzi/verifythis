module top;
   // Importamos el uvm_pkg que contiene todas las definiciones de macros y clases de UVM
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   // Este pkg tiene nuestras definiciones de clases y macros
   import   tinyalu_pkg::*;
   `include "tinyalu_macros.svh"

   // Instanciamos la BFM y DUT tal como hicimos previamente
   tinyalu_bfm       bfm();
   tinyalu DUT (.A(bfm.A), .B(bfm.B), .op(bfm.op), 
                .clk(bfm.clk), .reset_n(bfm.reset_n), 
                .start(bfm.start), .done(bfm.done), .result(bfm.result));

initial begin
  // Primer Cambio: Antes instanciamos el TB y le pasamos como parametro el BFM
  // con UVM no podemos hacer esto, ya que emplea un constructor con argumentos especificos
  // Por eso utilizamos un feature de UVM:
  //                  -> uvm_config_db

  // null y * : Le dicen al config que es visible en todo el TB
  // 3er argumento: nombre que le ponemos al dato dentro de la db
  // 4to argumento: que estamos guardando
  uvm_config_db #(virtual tinyalu_bfm)::set(null, "*", "bfm", bfm);

  // Cuando llamamos a run_test() en el modulo top, UVM lee el parametro que le pasamos (TBname)
  // y crea un objeto de esa clase de test utilizando la factory.
  run_test();
  // Este es nuestro primero paso, ahora debemos definir los tests.
end

endmodule : top