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

   // Polymorphism: do_copy takes a class derived from trago as its argument
   // so the trago class is what gets used as the argument type
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

   //do_copy passes the argument up to its parent class
   function void do_copy(trago copia);
      fernet_con_hielo copia_fernet_con_hielo;
      super.do_copy(copia);
      // Then the copy gets cast to a variable of its own class type
      $cast(copia_fernet_con_hielo, copia);
      this.medidas = copia_fernet_con_hielo.medidas;
   endfunction : do_copy

endclass : fernet_con_hielo
