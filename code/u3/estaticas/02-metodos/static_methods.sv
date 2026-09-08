// Metodos Statics
virtual class trago;
   protected int hielos = -1;

   function new(int hielos);
      set_age(hielos);
   endfunction : new

   function void set_age(int a);
      hielos = a;
   endfunction : set_age

   function int get_age();
      if (hielos == -1) $fatal(1, "You didn't set the hielos.");
      else return hielos;
   endfunction : get_age

   pure virtual function void servir();

endclass : trago

class fernet extends trago;

   protected string name;

   function new(int hielos, string n);
      super.new(hielos);
      name = n;
   endfunction : new

   function void servir();
      $display("%s: 70/30, y la coca al final", get_name());
   endfunction : servir

   function string get_name();
      return name;
   endfunction : get_name

endclass : fernet

class bandeja_de_fernet;

   protected static fernet vasos[$];

   static function void bandeja_fernet(fernet l);
      vasos.push_back(l);
   endfunction : bandeja_fernet

   static function void lista_fernets();
      $display("Fernets en la bandeja:");
      foreach (vasos[i]) $display(vasos[i].get_name());
   endfunction : lista_fernets

endclass : bandeja_de_fernet

module top;

   initial begin
      fernet fernet_h;
      fernet_h = new(2, "Kimba");
      bandeja_de_fernet::bandeja_fernet(fernet_h);
      fernet_h = new(3, "el de la mesa 4");
      bandeja_de_fernet::bandeja_fernet(fernet_h);
      fernet_h = new(15, "el de la barra");
      bandeja_de_fernet::bandeja_fernet(fernet_h);
      bandeja_de_fernet::lista_fernets();
   end

endmodule : top
