module top;

  // Guardamos las definiciones de clase y recursos compartidos en un package
  import   tinyalu_pkg::*;
  // Los macros que utilizamos tambien los definimos en comun. Esto tmb lo hace UVM
  `include "tinyalu_macros.svh"
   

  // Instanciamos la DUT y el BFM 
  tinyalu DUT (.A(bfm.A), .B(bfm.B), .op(bfm.op), 
                .clk(bfm.clk), .reset_n(bfm.reset_n), 
                .start(bfm.start), .done(bfm.done), .result(bfm.result));

  tinyalu_bfm     bfm();

  // Declaramos una variable que contenga nuestro TB
  testbench    testbench_h;
   
  initial begin
      // Instanciamos y lanzamos el objeto testbench
      testbench_h = new(bfm);
      testbench_h.execute();
  end
   
endmodule : top