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

// bandeja no es estatica ahora
class bandeja #(
    type T
);

   protected T vasos[$];

   function void bandeja_trago(T l);
      vasos.push_back(l);
   endfunction : bandeja_trago

   function void lista_tragos();
      $display("Tragos en la bandeja:");
      foreach (vasos[i]) $display(vasos[i].get_name());
   endfunction : lista_tragos

endclass : bandeja

module top;

   // Como bandeja no es estatica, debemos instanciarla
   // el parametro es un tipo de variable
   // Si usamos como parametro un tipo que no tiene el
   // metodo get_name() hay error de sintaxis
   fernet fernet_h;
   gancia gancia_h;

   bandeja #(fernet) bandeja_de_fernet;
   bandeja #(gancia) bandeja_de_gancia;

   initial begin
      bandeja_de_fernet = new();
      fernet_h = new(15, "el de la barra");
      bandeja_de_fernet.bandeja_trago(fernet_h);
      fernet_h = new(15, "el de la mesa 4");
      bandeja_de_fernet.bandeja_trago(fernet_h);

      bandeja_de_gancia = new();
      gancia_h = new(1, "el de la mesa 7");
      bandeja_de_gancia.bandeja_trago(gancia_h);

      gancia_h = new(1, "el de la vereda");
      bandeja_de_gancia.bandeja_trago(gancia_h);

      $display("-- Fernets --");
      bandeja_de_fernet.lista_tragos();
      $display("-- Gancias --");
      bandeja_de_gancia.lista_tragos();
   end

endmodule : top
