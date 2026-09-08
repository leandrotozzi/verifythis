// Variables Static
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

// Static Variable to handle global var
// Solo tenemos una copia en memoria de una variable static
// sin importar cuantas intancias de la clase tengamos
// Son como variables globales creadas de una forma controlada

class bandeja_de_fernet;
   //Queue static
   static fernet vasos[$];

endclass : bandeja_de_fernet

module top;
   initial begin
      fernet fernet_h;
      fernet_h = new(2, "Kimba");
      // :: operator
      //----------------
      //   Accedemos a la variable en la clase bandeja_de_fernet
      //   mencionando la clase y poniendo el operador :: antes de su nombre
      //   Esto le dice al compilador que queremos acceder a una variable static dentro
      //   del namespace de la clase
      bandeja_de_fernet::vasos.push_back(fernet_h);
      fernet_h = new(3, "el de la mesa 4");
      bandeja_de_fernet::vasos.push_back(fernet_h);
      fernet_h = new(15, "el de la barra");

      // clase::variable_static. Inmediatamente sabemos donde esta declarada
      bandeja_de_fernet::vasos.push_back(fernet_h);

      $display("Fernets en la bandeja:");
      foreach (bandeja_de_fernet::vasos[i]) $display(bandeja_de_fernet::vasos[i].get_name());
   end
endmodule : top
