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

class con_alcohol extends trago;
   int graduacion;
   function new(int a = 0, b = 0);
      super.new(a);
      graduacion = b;
   endfunction : new

   function string convert2string();
      return {
         super.convert2string(), $sformatf("\ngraduacion: %0d", graduacion)
      };
   endfunction : convert2string

   function void do_copy(trago copia);
      con_alcohol copia_con_alcohol;
      super.do_copy(copia);
      $cast(copia_con_alcohol, copia);
      graduacion = copia_con_alcohol.graduacion;
   endfunction : do_copy
endclass : con_alcohol

class fernet extends con_alcohol;
   bit con_coca;

   function new(int hielos = 0, int graduacion = 0, bit con_coca = 0);
      super.new(hielos, graduacion);
      this.con_coca = con_coca;
   endfunction : new

   function string convert2string();
      string coca_s;
      coca_s = (con_coca) ? "si" : "no";
      return {super.convert2string(), "\nCoca: ", coca_s};
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

   function new(int hielos = 0, int graduacion = 0, bit con_coca = 0,
                string mesa = "");
      super.new(hielos, graduacion, con_coca);
      this.mesa = mesa;
   endfunction : new

   function string convert2string();
      return {super.convert2string(), "\nMesa: ", mesa};
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

   function new(int hielos = 0, bit con_coca = 0, int graduacion = 0,
                string mesa = "", byte medidas = 0);
      super.new(hielos, graduacion, con_coca, mesa);
      this.medidas = medidas;
   endfunction : new

   function string convert2string();
      return {super.convert2string(), "\n", $sformatf("medidas: %0d", medidas)};
   endfunction : convert2string

   function void do_copy(trago copia);
      fernet_con_hielo copia_fernet_con_hielo;
      super.do_copy(copia);
      $cast(copia_fernet_con_hielo, copia);
      this.medidas = copia_fernet_con_hielo.medidas;
   endfunction : do_copy

endclass : fernet_con_hielo

module top;
   fernet_con_hielo fernet_hielo1_h, fernet_hielo2_h;

   initial begin
      fernet_hielo1_h = new
          (.hielos(2), .con_coca(1), .graduacion(2), .mesa("mesa 4"), .medidas(2));
      $display("\n--- Fernet 1 ---\n", fernet_hielo1_h.convert2string());
      fernet_hielo2_h = new();
      $display("\n--- Fernet 2 before the copy ---\n", fernet_hielo2_h.convert2string());
      fernet_hielo2_h.do_copy(fernet_hielo1_h);
      $display("\n--- Fernet 2 after the copy ---\n", fernet_hielo2_h.convert2string());
   end
endmodule : top

