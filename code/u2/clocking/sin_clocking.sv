// El muestreo a mano: sin clocking block hay que elegir el flanco Y el delta,
// en cada task, una y otra vez. Este top corre las tres variantes que se
// escriben la primera semana y muestra que dan TRES numeros distintos.
//
//   bash run.sh
module dut_reg (input bit clk, input byte unsigned d_in, output byte unsigned d_out);
   // El DUT cuenta: en cada flanco, la salida pasa a ser la entrada + 1.
   always_ff @(posedge clk) d_out <= d_in + 8'd1;
endmodule

module top_sin;
   bit           clk = 0;
   byte unsigned d_in, d_out;

   always #5 clk = ~clk;
   dut_reg u_dut (.*);

   byte unsigned en_el_flanco, un_delta_despues, en_el_flanco_opuesto;

   initial begin
      d_in = 8'd10;

      // 1. Muestrear EN el flanco. El always_ff del DUT actualiza d_out con una
      //    asignacion no bloqueante, que se aplica despues de que este initial
      //    ya corrio: se lee el valor VIEJO.
      @(posedge clk);
      en_el_flanco = d_out;

      // 2. El mismo flanco, un delta mas tarde. Ahora la no bloqueante ya se
      //    aplico y se lee el valor NUEVO. El "#1" no se ve en ningun lado y
      //    cambia el resultado.
      @(posedge clk);
      #1;
      un_delta_despues = d_out;

      // 3. El flanco opuesto: el truco que usa toda la BFM del curso. Anda,
      //    pero le pide al que lo lee que sepa por que.
      @(negedge clk);
      en_el_flanco_opuesto = d_out;

      $display("d_in = %0d, y el DUT calcula d_in + 1 = %0d", 8'd10, 8'd11);
      $display("  muestreado EN el posedge      : %0d", en_el_flanco);
      $display("  muestreado un delta despues   : %0d", un_delta_despues);
      $display("  muestreado en el negedge      : %0d", en_el_flanco_opuesto);
      $display("");
      $display("Tres lineas que parecen lo mismo y no lo son. Y la decision");
      $display("esta repetida en cada task de la interface.");
      $finish;
   end
endmodule : top_sin
