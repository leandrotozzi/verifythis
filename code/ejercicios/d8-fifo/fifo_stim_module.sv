// El modulo de siempre: maneja la FIFO a mano, sin UVM. Se da hecho, y no se
// toca.
//
// Corre solo con +STIM, que es lo que el corrector le pasa a monitor_test.
// Hace DOCE ciclos con actividad -- escrituras, lecturas y una simultanea --
// y tu monitor tiene que verlos todos y ninguno de mas.
module fifo_stim_module (fifo_if bfm);

   // El protocolo es de un ciclo: se levantan las senales en el flanco de
   // bajada y el DUT las toma en el de subida. Igual que la BFM del VTALU.
   task automatic ciclo(input bit wr, input bit [7:0] dato, input bit rd);
      @(negedge bfm.clk);
      bfm.wr_en   = wr;
      bfm.wr_data = dato;
      bfm.rd_en   = rd;
      @(negedge bfm.clk);
      bfm.wr_en = 1'b0;
      bfm.rd_en = 1'b0;
   endtask : ciclo

   initial begin
      bfm.wr_en   = 1'b0;
      bfm.rd_en   = 1'b0;
      bfm.wr_data = 8'h00;
      bfm.rst_n   = 1'b0;
      repeat (2) @(negedge bfm.clk);
      bfm.rst_n = 1'b1;

      // Solo con +STIM: en los tests que maneja el testbench, esta FIFO se
      // queda quieta.
      if ($test$plusargs("STIM")) begin
         ciclo(1, 8'hA0, 0);  // 1  escribe
         ciclo(1, 8'hA1, 0);  // 2
         ciclo(1, 8'hA2, 0);  // 3
         ciclo(0, 8'h00, 1);  // 4  lee: A0 sale en el ciclo 5
         ciclo(1, 8'hA3, 1);  // 5  simultanea: entra A3 y sale A1
         ciclo(0, 8'h00, 1);  // 6
         ciclo(0, 8'h00, 1);  // 7
         ciclo(0, 8'h00, 1);  // 8  la FIFO queda vacia
         ciclo(0, 8'h00, 1);  // 9  lee vacia: NO pasa nada, y no es un error
         ciclo(1, 8'hB0, 0);  // 10
         ciclo(1, 8'hB1, 0);  // 11
         ciclo(0, 8'h00, 1);  // 12
      end
   end

endmodule : fifo_stim_module
