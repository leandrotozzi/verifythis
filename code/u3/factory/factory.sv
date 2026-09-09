// Example: the factory pattern
virtual class trago;
   protected int hielos = -1;
   protected string name;

   function new(int a, string n);
      hielos = a;
      name = n;
   endfunction : new

   function int get_hielos();
      return hielos;
   endfunction : get_hielos

   function string get_name();
      return name;
   endfunction : get_name

   pure virtual function void servir();
endclass : trago

class fernet extends trago;

   // This variable belongs to fernet, but does not exist in trago
   bit sin_hielo = 0;

   function new(int hielos, string n);
      super.new(hielos, n);
   endfunction : new

   function void servir();
      $display("The fernet %s: 70/30, and the coke last", get_name());
   endfunction : servir

endclass : fernet

class mojito extends trago;
   function new(int hielos, string n);
      super.new(hielos, n);
   endfunction : new

   function void servir();
      $display("The mojito %s: mint, lime and crushed ice", get_name());
   endfunction : servir
endclass : mojito

//*********************************************************************
// Part of the factory Class!
//*********************************************************************
class cantina;

   // Static method that builds the drinks
   static function trago hacer_trago(string pedido, int hielos, string name);
      mojito nuevo_mojito;
      fernet nuevo_fernet;
      case (pedido)
         "fernet": begin
            nuevo_fernet = new(hielos, name);
            return nuevo_fernet;
         end

         "mojito": begin
            nuevo_mojito = new(hielos, name);
            return nuevo_mojito;
         end

         default: $fatal(1, {"No such drink: ", pedido});

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
      $display("Drinks on the tray:");
      foreach (vasos[i]) $display(vasos[i].get_name());
   endfunction : lista_tragos

endclass : bandeja

module top;

   initial begin
      trago trago_h;
      fernet fernet_h;
      mojito mojito_h;
      bit cast_ok;

      // cb: casting
      // Using the factory!
      trago_h = cantina::hacer_trago("fernet", 15, "the one at the bar");
      trago_h.servir();

      // Reaching a member of fernet (derived from trago) through a trago variable
      // requires casting it to fernet.
      cast_ok = $cast(fernet_h, trago_h);
      if (!cast_ok) $fatal(1, "Could not cast trago_h to fernet_h");

      if (fernet_h.sin_hielo) $display("And on top of that it comes warm!");
      bandeja#(fernet)::bandeja_trago(fernet_h);

      if (!$cast(fernet_h, cantina::hacer_trago("fernet", 2, "the one at table 4")))
         $fatal(1, "Could not cast the cantina drink to fernet_h");
      // cb: end

      bandeja#(fernet)::bandeja_trago(fernet_h);

      if (!$cast(mojito_h, cantina::hacer_trago("mojito", 1, "the one at table 7")))
         $fatal(1, "Could not cast the cantina result to mojito_h");

      bandeja#(mojito)::bandeja_trago(mojito_h);

      if (!$cast(mojito_h, cantina::hacer_trago("mojito", 1, "the one on the sidewalk")))
         $fatal(1, "Could not cast the cantina result to mojito_h");

      bandeja#(mojito)::bandeja_trago(mojito_h);

      $display("-- Fernets --");
      bandeja#(fernet)::lista_tragos();
      $display("-- Mojitos --");
      bandeja#(mojito)::lista_tragos();
   end

endmodule : top
