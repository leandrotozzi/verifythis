// Una transferencia de APB, entera: el pedido y la respuesta en el mismo
// objeto. Se puede porque en APB no hay transacciones solapadas -- en AXI esto
// serian dos clases y un ID para aparearlas.
class apb_transaction extends uvm_sequence_item;
   `uvm_object_utils(apb_transaction)

   rand bit        write;
   rand bit [ 7:0] addr;
   rand bit [31:0] wdata;

   // La respuesta: no es rand. La escribe el driver cuando vuelve del bus, y
   // la escribe el monitor cuando lo ve pasar.
   bit [31:0]      rdata;
   bit             slverr;

   // Las direcciones se listan una por una y todas alineadas, en vez de poner
   // un rango y pedir addr[1:0]==0 aparte: Verilator no combina un dist con
   // otra constraint sobre la misma variable, y avisa con UNSATCONSTR --
   // ruidoso, pero avisa. Ver docs/verilator.md.
   // Una de cada seis cae fuera del mapa: sin eso el bin unmapped del plan de
   // verificacion no se llena nunca.
   constraint c_addr {
      addr dist {
         CTRL_ADDR :/ 3, SCRATCH_ADDR :/ 3, ACC_ADDR :/ 2, STATUS_ADDR :/ 2,
         8'h10 :/ 1, 8'h14 :/ 1
      };
   }

   // La mitad de las escrituras a CTRL prenden EN, y una de cada cuatro pide
   // CLR. Sin sesgar esto, EN=1 sale en la mitad de los casos igual, pero CLR
   // -- que es un bit suelto de 32 -- no sale nunca.
   constraint c_ctrl {
      (addr == CTRL_ADDR && write) -> wdata inside {32'h0, 32'h1, 32'h2, 32'h3};
   }

   function new(string name = "");
      super.new(name);
   endfunction : new

   // El formato es el contrato con el corrector. Ver el README.
   function string convert2string();
      return $sformatf("%s @0x%02h = 0x%08h  slverr=%0d", write ? "WR" : "RD", addr,
                       write ? wdata : rdata, slverr);
   endfunction : convert2string

   function void do_copy(uvm_object rhs);
      apb_transaction copiada;
      if (rhs == null) `uvm_fatal("APB TRANSACTION", "Tried to copy from a null pointer")
      if (!$cast(copiada, rhs)) `uvm_fatal("APB TRANSACTION", "Tried to copy wrong type.")
      super.do_copy(rhs);
      write  = copiada.write;
      addr   = copiada.addr;
      wdata  = copiada.wdata;
      rdata  = copiada.rdata;
      slverr = copiada.slverr;
   endfunction : do_copy

endclass : apb_transaction
