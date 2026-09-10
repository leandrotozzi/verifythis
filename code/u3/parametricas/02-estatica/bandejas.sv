// Static Class version

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

// cb: tray-and-top
// Parameterized class
// the T (type) parameter is what says which
// kind of queue this is.
class bandeja #(
    type T
);

   protected static T vasos[$];

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
      fernet fernet_h;
      mojito mojito_h;
      fernet_h = new(15, "the one at the bar");
      bandeja#(fernet)::bandeja_trago(fernet_h);
      fernet_h = new(15, "the one at table 4");
      bandeja#(fernet)::bandeja_trago(fernet_h);

      mojito_h = new(1, "the one at table 7");
      bandeja#(mojito)::bandeja_trago(mojito_h);
      mojito_h = new(1, "the one at the counter");
      bandeja#(mojito)::bandeja_trago(mojito_h);

      $display("-- Fernets --");
      bandeja#(fernet)::lista_tragos();
      $display("-- Mojitos --");
      bandeja#(mojito)::lista_tragos();
   end

endmodule : top
// cb: end
