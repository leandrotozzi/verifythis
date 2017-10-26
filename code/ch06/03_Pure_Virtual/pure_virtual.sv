// Clases virtuales, solo pueden ser usadas como clases bases
// no las podemos instanciar directamente
virtual class animal;
   int age=-1;

   function new(int a);
      age = a;
   endfunction : new

   // Metodos pure virtual
   // no tienen body, debo redefinirlos si o su cuando extiendo la clase
   pure virtual function void make_sound();

endclass : animal


class lion extends animal;

   function new(int age);
      super.new(age);
   endfunction : new

   function void make_sound();
      $display ("The Lion says Roar");
   endfunction : make_sound

endclass : lion


class chicken extends animal;

   function new(int age);
      super.new(age);
   endfunction : new

   // Si no hago un override del metodo make_sound (pure virtual) explota
   // en tiempo de compilacion
   // # ** Error: pure_virtual.sv(30): Sub-class 'chicken' does not override virtual 
   //    method 'make_sound' of abstract superclass 'animal'.

   function void make_sound();
      $display ("The Chicken says BECAWW");
   endfunction : make_sound

endclass : chicken


module top;


   initial begin
   
      lion   lion_h;
      chicken  chicken_h;
      animal animal_h;
   
      // Esto NO lo podemos hacer ya que las clases abstractas no se pueden instanciar
      // animal_h = new(3); // WILL FAIL
      
      lion_h  = new(15);
      lion_h.make_sound();
      $display("The Lion is %0d years old", lion_h.age);
      
      chicken_h = new(1);
      chicken_h.make_sound();
      $display("The Chicken is %0d years old", chicken_h.age);

      animal_h = lion_h;
      animal_h.make_sound();
      $display("The animal is %0d years old", animal_h.age);
      
      animal_h = chicken_h;
      animal_h.make_sound();
      $display("The animal is %0d years old", animal_h.age);
      
   end // initial begin

endmodule : top