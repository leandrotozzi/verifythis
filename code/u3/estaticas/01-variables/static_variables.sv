// Static variables
virtual class trago;
   protected int hielos = -1;

   function new(int hielos);
      set_hielos(hielos);
   endfunction : new

   function void set_hielos(int a);
      hielos = a;
   endfunction : set_hielos

   function int get_hielos();
      if (hielos == -1) $fatal(1, "You didn't set the hielos.");
      else return hielos;
   endfunction : get_hielos

   pure virtual function void servir();

endclass : trago

class fernet extends trago;
   protected string name;

   function new(int hielos, string n);
      super.new(hielos);
      name = n;
   endfunction : new

   function void servir();
      $display("%s: 70/30, and the coke last", get_name());
   endfunction : servir

   function string get_name();
      return name;
   endfunction : get_name

endclass : fernet

// Static Variable to handle global var
// There is only one copy of a static variable in memory,
// no matter how many instances of the class exist
// They are global variables created in a controlled way

// cb: tray-and-top
class bandeja_de_fernet;
   //Queue static
   static fernet vasos[$];

endclass : bandeja_de_fernet

module top;
   initial begin
      fernet fernet_h;
      fernet_h = new(2, "the one at table 7");
      // :: operator
      //----------------
      //   The variable in the bandeja_de_fernet class is reached by
      //   naming the class and putting the :: operator before the name
      //   That tells the compiler we want a static variable inside
      //   the namespace of the class
      bandeja_de_fernet::vasos.push_back(fernet_h);
      fernet_h = new(3, "the one at table 4");
      bandeja_de_fernet::vasos.push_back(fernet_h);
      fernet_h = new(15, "the one at the bar");

      // class::static_variable. You know right away where it is declared
      bandeja_de_fernet::vasos.push_back(fernet_h);

      $display("Fernets on the tray:");
      foreach (bandeja_de_fernet::vasos[i]) $display(bandeja_de_fernet::vasos[i].get_name());
   end
endmodule : top
// cb: end
