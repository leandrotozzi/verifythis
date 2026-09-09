// Basic polymorphism, WITHOUT virtual: the case that fails. See unit 6.
// cb: three-classes
class trago;
   int hielos = -1;

   function new(int a);
      hielos = a;
   endfunction : new

   function void servir();
      $fatal(1, "A generic trago cannot be served: order a real one.");
   endfunction : servir

endclass : trago

class fernet extends trago;

   function new(int hielos);
      super.new(hielos);
   endfunction : new

   function void servir();
      $display("Fernet: 70/30, and the coke last");
   endfunction : servir

endclass : fernet
// cb: end

class mojito extends trago;

   function new(int hielos);
      super.new(hielos);
   endfunction : new

   function void servir();
      $display("Mojito: mint, lime and crushed ice");
   endfunction : servir

endclass : mojito

module top;

   initial begin

      fernet fernet_h;
      mojito mojito_h;
      trago  trago_h;

      // cb: the-calls
      fernet_h = new(15);
      fernet_h.servir();
      $display("The fernet has %0d ice cubes", fernet_h.hielos);

      mojito_h = new(1);
      mojito_h.servir();
      $display("The mojito has %0d ice cubes", mojito_h.hielos);

      // The variable is trago, the object is fernet.
      trago_h = fernet_h;
      trago_h.servir();  // ** Fatal: A generic trago cannot be served
      $display("The trago has %0d ice cubes", trago_h.hielos);

      trago_h = mojito_h;
      trago_h.servir();
      $display("The trago has %0d ice cubes", trago_h.hielos);
      // cb: end

   end  // initial begin

endmodule : top
