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

   // Polimorfismo: do_copy toma como argumento una clase derivada de trago
   // por lo tanto, usamos la clase trago como argumento
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

   //do_copy pasa el argumento a su clase superior
   function void do_copy(trago copia);
      fernet_con_hielo copia_fernet_con_hielo;
      super.do_copy(copia);
      // Luego casteamos copia a una variable de su tipo de clase
      $cast(copia_fernet_con_hielo, copia);
      this.medidas = copia_fernet_con_hielo.medidas;
   endfunction : do_copy

endclass : fernet_con_hielo
