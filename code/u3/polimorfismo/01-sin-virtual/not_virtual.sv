// Polimorfismo basico, SIN virtual: el caso que falla. Ver la unidad 6.
class trago;
   int hielos = -1;

   function new(int a);
      hielos = a;
   endfunction : new

   function void servir();
      $fatal(1, "Un trago generico no se sirve: pedi uno.");
   endfunction : servir

endclass : trago

class fernet extends trago;

   function new(int hielos);
      super.new(hielos);
   endfunction : new

   function void servir();
      $display("Fernet: 70/30, y la coca al final");
   endfunction : servir

endclass : fernet

class gancia extends trago;

   function new(int hielos);
      super.new(hielos);
   endfunction : new

   function void servir();
      $display("Gancia: con Sprite y una rodaja de limon");
   endfunction : servir

endclass : gancia

module top;

   initial begin

      fernet    fernet_h;
      gancia gancia_h;
      trago  trago_h;

      fernet_h = new(15);
      fernet_h.servir();
      $display("El fernet lleva %0d hielos", fernet_h.hielos);

      gancia_h = new(1);
      gancia_h.servir();
      $display("El gancia lleva %0d hielos", gancia_h.hielos);

      // La variable es trago, el objeto es fernet.
      trago_h = fernet_h;
      trago_h.servir();  // ** Fatal: Un trago generico no se sirve
      $display("El trago lleva %0d hielos", trago_h.hielos);

      trago_h = gancia_h;
      trago_h.servir();
      $display("El trago lleva %0d hielos", trago_h.hielos);

   end  // initial begin

endmodule : top
