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

// bandeja is not static any more
class bandeja #(
    type T
);

   protected T vasos[$];

   function void bandeja_trago(T l);
      vasos.push_back(l);
   endfunction : bandeja_trago

   function void lista_tragos();
      $display("Drinks on the tray:");
      foreach (vasos[i]) $display(vasos[i].get_name());
   endfunction : lista_tragos

endclass : bandeja

module top;

   // Since bandeja is not static, it has to be instantiated
   // the parameter is a variable type
   // Using a type that does not have the get_name()
   // method is a syntax error
   fernet fernet_h;
   mojito mojito_h;

   bandeja #(fernet) bandeja_de_fernet;
   bandeja #(mojito) bandeja_de_mojito;

   initial begin
      bandeja_de_fernet = new();
      fernet_h = new(15, "the one at the bar");
      bandeja_de_fernet.bandeja_trago(fernet_h);
      fernet_h = new(15, "the one at table 4");
      bandeja_de_fernet.bandeja_trago(fernet_h);

      bandeja_de_mojito = new();
      mojito_h = new(1, "the one at table 7");
      bandeja_de_mojito.bandeja_trago(mojito_h);

      mojito_h = new(1, "the one on the sidewalk");
      bandeja_de_mojito.bandeja_trago(mojito_h);

      $display("-- Fernets --");
      bandeja_de_fernet.lista_tragos();
      $display("-- Mojitos --");
      bandeja_de_mojito.lista_tragos();
   end

endmodule : top
