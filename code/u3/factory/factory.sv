// Ejemplo: Factory
virtual class trago;
   protected int hielos = -1;
   protected string name;

   function new(int a, string n);
      hielos = a;
      name = n;
   endfunction : new

   function int get_age();
      return hielos;
   endfunction : get_age

   function string get_name();
      return name;
   endfunction : get_name

   pure virtual function void servir();
endclass : trago

class fernet extends trago;

   // Esta variable pertenece a fernet, pero no existe en trago
   bit sin_hielo = 0;

   function new(int hielos, string n);
      super.new(hielos, n);
   endfunction : new

   function void servir();
      $display("El fernet %s: 70/30, y la coca al final", get_name());
   endfunction : servir

endclass : fernet

class gancia extends trago;
   function new(int hielos, string n);
      super.new(hielos, n);
   endfunction : new

   function void servir();
      $display("El gancia %s: con Sprite y una rodaja de limon", get_name());
   endfunction : servir
endclass : gancia

//*********************************************************************
// Parte de la factory Class!
//*********************************************************************
class cantina;

   // Metodo estatico para crear los tragos
   static function trago hacer_trago(string pedido, int hielos, string name);
      gancia nuevo_gancia;
      fernet    nuevo_fernet;
      case (pedido)
         "fernet": begin
            nuevo_fernet = new(hielos, name);
            return nuevo_fernet;
         end

         "gancia": begin
            nuevo_gancia = new(hielos, name);
            return nuevo_gancia;
         end

         default: $fatal(1, {"No hay ese trago: ", pedido});

      endcase  // case (pedido)

   endfunction : hacer_trago

endclass : cantina

class bandeja #(
    type T = trago
);

   static T vasos[$];

   static function void bandeja_trago(T l);
      vasos.push_back(l);
   endfunction : bandeja_trago

   static function void lista_tragos();
      $display("Tragos en la bandeja:");
      foreach (vasos[i]) $display(vasos[i].get_name());
   endfunction : lista_tragos

endclass : bandeja

module top;

   initial begin
      trago trago_h;
      fernet fernet_h;
      gancia gancia_h;
      bit cast_ok;

      // Usamos la factory!
      trago_h = cantina::hacer_trago("fernet", 15, "el de la barra");
      trago_h.servir();

      // Para acceder a un miembro de fernet (derivado de trago) mediante una variable trago
      // es necesario castearlo a fernet.
      cast_ok = $cast(fernet_h, trago_h);
      if (!cast_ok) $fatal(1, "No se pudo castear trago_h a fernet_h");

      if (fernet_h.sin_hielo) $display("Y encima viene tibio!");
      bandeja#(fernet)::bandeja_trago(fernet_h);

      if (!$cast(fernet_h, cantina::hacer_trago("fernet", 2, "el de la mesa 4")))
         $fatal(1, "No se pudo castear el trago de la cantina a fernet_h");

      bandeja#(fernet)::bandeja_trago(fernet_h);

      if (!$cast(gancia_h, cantina::hacer_trago("gancia", 1, "Clucker")))
         $fatal(1, "No se pudo castear el resultado de la cantina a gancia_h");

      bandeja#(gancia)::bandeja_trago(gancia_h);

      if (!$cast(gancia_h, cantina::hacer_trago("gancia", 1, "Boomer")))
         $fatal(1, "No se pudo castear el resultado de la cantina a gancia_h");

      bandeja#(gancia)::bandeja_trago(gancia_h);

      $display("-- Fernets --");
      bandeja#(fernet)::lista_tragos();
      $display("-- Gancias --");
      bandeja#(gancia)::lista_tragos();
   end

endmodule : top
