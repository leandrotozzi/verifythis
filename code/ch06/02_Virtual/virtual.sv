// La unica diferencia de este codigo con el anterior, es que ahora
// el metodo make_sound() de animal es virtual
// Luego no tenemos el error anterior

class animal;
   int age=-1;

   function new(int a);
      age = a;
   endfunction : new

   virtual function void make_sound();
      $fatal(1, "Generic animals don't have a sound.");
   endfunction : make_sound

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

   function void make_sound();
      $display ("The Chicken says BECAWW");
   endfunction : make_sound

endclass : chicken


module top;


   initial begin
   
      lion   lion_h;
      chicken  chicken_h;
      animal animal_h;
      
      lion_h  = new(15);
      lion_h.make_sound();
      $display("The Lion is %0d years old", lion_h.age);
      
      // Ahora como definimos el metodo como virtual
      // SV se fija en que tipo de objeto tiene la variable
      // y llama el metodo correcto
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