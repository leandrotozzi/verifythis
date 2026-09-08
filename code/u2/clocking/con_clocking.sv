// El mismo DUT, con clocking block: el flanco y el delta se declaran UNA vez,
// adentro de la interface, y ninguna task vuelve a elegirlos.
//
//   bash run.sh
module dut_reg (input bit clk, input byte unsigned d_in, output byte unsigned d_out);
   always_ff @(posedge clk) d_out <= d_in + 8'd1;
endmodule

interface reg_bfm (input bit clk);
   byte unsigned d_in, d_out;

   // Las dos unicas lineas de temporizado del testbench:
   //   input  #1step  muestrea el valor ESTABLE justo antes del flanco, que es
   //                  lo que ve el hardware. Nunca lo que la no bloqueante
   //                  acaba de escribir en ese mismo flanco.
   //   output #0      maneja EN el flanco, en la region de las no bloqueantes,
   //                  asi que el DUT no lo ve hasta el flanco siguiente.
   clocking cb @(posedge clk);
      default input #1step output #0;
      output d_in;
      input  d_out;
   endclocking

   modport tb (clocking cb);
endinterface : reg_bfm

module top_con;
   bit clk = 0;
   always #5 clk = ~clk;

   reg_bfm bfm (clk);
   dut_reg u_dut (.clk(clk), .d_in(bfm.d_in), .d_out(bfm.d_out));

   byte unsigned primera, segunda, tercera;

   initial begin
      // Manejar es "<=" contra el clocking block. No hay flanco que elegir.
      bfm.cb.d_in <= 8'd10;

      // @(bfm.cb) es "esperar el flanco de este clocking block". Van TRES, y
      // el motivo es la leccion entera:
      //   1er flanco  el output #0 recien pone d_in en 10, en la region de las
      //               no bloqueantes, asi que el DUT todavia no lo vio.
      //   2do flanco  ahora si el DUT toma d_in=10 y calcula d_out <= 11.
      //   3er flanco  el input #1step muestrea el valor ESTABLE antes de este
      //               flanco, que ya es 11.
      // Un testbench sin clocking block tapa esto con un #1 y funciona por
      // accidente. Aca la cuenta esta a la vista y no depende del simulador.
      @(bfm.cb);
      @(bfm.cb);
      @(bfm.cb);

      // Y muestrear es leer cb.d_out. Se lee tres veces, en tres momentos
      // distintos del mismo ciclo, y da lo mismo las tres: ese es el punto.
      primera = bfm.cb.d_out;
      #2;
      segunda = bfm.cb.d_out;
      #3;
      tercera = bfm.cb.d_out;

      $display("d_in = %0d, y el DUT calcula d_in + 1 = %0d", 8'd10, 8'd11);
      $display("  cb.d_out, apenas pasa el flanco : %0d", primera);
      $display("  cb.d_out, dos unidades despues  : %0d", segunda);
      $display("  cb.d_out, cinco despues         : %0d", tercera);
      $display("");
      $display("El mismo numero las tres veces, y ni un solo #1 en el testbench.");
      $display("El flanco y el delta se declararon una vez, en el clocking block.");

      if (primera != 8'd11 || segunda != 8'd11 || tercera != 8'd11)
        $fatal(1, "el clocking block deberia dar 11 las tres veces");
      $finish;
   end
endmodule : top_con
