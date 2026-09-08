// Static Class version

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

   protected string name;

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

// Parameterized class
// mediante el parametro T (type) especificamos que
// tipo de queue es.
class bandeja #(
    type T
);

   protected static T vasos[$];

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
      fernet fernet_h;
      gancia gancia_h;
      fernet_h = new(15, "el de la barra");
      bandeja#(fernet)::bandeja_trago(fernet_h);
      fernet_h = new(15, "el de la mesa 4");
      bandeja#(fernet)::bandeja_trago(fernet_h);

      gancia_h = new(1, "Clucker");
      bandeja#(gancia)::bandeja_trago(gancia_h);
      gancia_h = new(1, "Scratchy");
      bandeja#(gancia)::bandeja_trago(gancia_h);

      $display("-- Fernets --");
      bandeja#(fernet)::lista_tragos();
      $display("-- Gancias --");
      bandeja#(gancia)::lista_tragos();
   end

endmodule : top
