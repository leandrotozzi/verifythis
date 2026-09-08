// El modulo de siempre: maneja su APB a mano, sin UVM y sin las tasks de la
// interface. Se da hecho, y no se toca.
//
// Corre solo con +STIM, que es lo que el corrector le pasa a monitor_test.
// Son OCHO transferencias, y las ocho respetan el protocolo. Tu monitor tiene
// que verlas todas y ninguna de mas.
module apb_stim_module (apb_if bfm);

   // El protocolo escrito a mano, igual que lo hizo el que escribio esto en
   // 2014: SETUP en un flanco de bajada, ACCESS en el siguiente, y PREADY
   // muestreado en el de subida.
   task automatic xfer(input bit wr, input bit [7:0] addr, input bit [31:0] data);
      @(negedge bfm.PCLK);
      bfm.PSEL = 1'b1;
      bfm.PENABLE = 1'b0;
      bfm.PWRITE = wr;
      bfm.PADDR = addr;
      bfm.PWDATA = data;
      @(negedge bfm.PCLK);
      bfm.PENABLE = 1'b1;
      do @(posedge bfm.PCLK); while (bfm.PREADY !== 1'b1);
      @(negedge bfm.PCLK);
      bfm.PSEL = 1'b0;
      bfm.PENABLE = 1'b0;
   endtask : xfer

   initial begin
      bfm.PSEL = 1'b0;
      bfm.PENABLE = 1'b0;
      bfm.PWRITE = 1'b0;
      bfm.PADDR = 8'h00;
      bfm.PWDATA = 32'h0;
      bfm.PRESETn = 1'b0;
      repeat (2) @(negedge bfm.PCLK);
      bfm.PRESETn = 1'b1;

      // Solo con +STIM: en los tests que maneja el testbench, este bus se
      // queda quieto.
      if ($test$plusargs("STIM")) begin
         xfer(1, 8'h00, 32'h0000_0001);  // EN = 1
         xfer(1, 8'h04, 32'h0000_0010);  // SCRATCH, ACC = 0x10
         xfer(1, 8'h04, 32'h0000_0020);  // SCRATCH, ACC = 0x30
         xfer(0, 8'h08, 32'h0);          // lee ACC
         xfer(0, 8'h04, 32'h0);          // lee SCRATCH
         xfer(1, 8'h08, 32'h0000_00FF);  // escribe ACC: se ignora, y NO da error
         xfer(0, 8'h10, 32'h0);          // fuera del mapa: PSLVERR
         xfer(0, 8'h0C, 32'h0);          // lee STATUS
      end
   end

endmodule : apb_stim_module
