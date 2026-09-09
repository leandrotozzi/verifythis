virtual class trago;
   int hielos = -1;

   function new(int a = 0);
      hielos = a;
   endfunction : new

   virtual function string convert2string();
      return $sformatf("Hielos: %0d", hielos);
   endfunction : convert2string

   virtual function void do_copy(trago copia);
      hielos = copia.hielos;
   endfunction : do_copy

endclass : trago

class fernet extends trago;
   bit con_coca;

   function new(int hielos = 0, bit con_coca = 0);
      super.new(hielos);
      this.con_coca = con_coca;
   endfunction : new

   function string convert2string();
      string coca_s;
      coca_s = (con_coca) ? "si" : "no";
      return $sformatf("Hielos: %0d  Coca: %s", hielos, coca_s);
   endfunction : convert2string

   function void do_copy(trago copia);
      fernet copia_fernet;
      super.do_copy(copia);
      $cast(copia_fernet, copia);
      this.con_coca = copia_fernet.con_coca;
   endfunction : do_copy

endclass : fernet

class fernet_doble extends fernet;
   string mesa;

   function new(int hielos = 0, bit con_coca = 0, string mesa = "");
      super.new(hielos, con_coca);
      this.mesa = mesa;
   endfunction : new

   function string convert2string();
      return {$sformatf("hielos: %0d  coca: %0b  mesa: %s", hielos, con_coca, mesa)};
   endfunction : convert2string

   function void do_copy(trago copia);
      fernet_doble copia_fernet_doble;
      super.do_copy(copia);
      $cast(copia_fernet_doble, copia);
      this.mesa = copia_fernet_doble.mesa;
   endfunction : do_copy
endclass : fernet_doble

class fernet_con_hielo extends fernet_doble;
   byte medidas;

   function new(int hielos = 0, bit con_coca = 0, string mesa = "", byte medidas = 0);
      super.new(hielos, con_coca, mesa);
      this.medidas = medidas;
   endfunction : new

   function string convert2string();
      return {
         $sformatf(
             "hielos: %0d  coca: %0b  mesa: %s  medidas: %0d",
             hielos,
             con_coca,
             mesa,
             medidas
         )
      };
   endfunction : convert2string

   function void do_copy(trago copia);
      fernet_con_hielo copia_fernet_con_hielo;
      super.do_copy(copia);
      $cast(copia_fernet_con_hielo, copia);
      this.medidas = copia_fernet_con_hielo.medidas;
   endfunction : do_copy

   function void bad_copy(fernet_con_hielo copia_fernet_con_hielo);
      medidas = copia_fernet_con_hielo.medidas;
      mesa = copia_fernet_con_hielo.mesa;
      con_coca = copia_fernet_con_hielo.con_coca;
      hielos = copia_fernet_con_hielo.hielos;
   endfunction

endclass : fernet_con_hielo

module top;
   fernet_con_hielo fernet_hielo1_h, fernet_hielo2_h;

   initial begin
      fernet_hielo1_h = new(2, 1, "Agnus", 2);
      $display("\n--- Fernet 1 ---\n", fernet_hielo1_h.convert2string());
      fernet_hielo2_h = new();
      $display("\n--- Fernet 2 before the copy ---\n", fernet_hielo2_h.convert2string());
      fernet_hielo2_h.bad_copy(fernet_hielo1_h);
      $display("\n--- Fernet 2 after the copy ---\n", fernet_hielo2_h.convert2string());
   end
endmodule : top

