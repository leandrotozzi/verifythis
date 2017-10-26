// Polimorfismo Basico. Not Virtual
class animal;
   int age=-1;

   function new(int a);
      age = a;
   endfunction : new

   // Si intentamos que un animal generico haga ruido, es un error
   function void make_sound();
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
   
      lion    lion_h;
      chicken chicken_h;
      animal  animal_h;
      
      lion_h  = new(15);
      lion_h.make_sound();
      $display("The Lion is %0d years old", lion_h.age);
      
      chicken_h = new(1);
      chicken_h.make_sound();
      $display("The Chicken is %0d years old", chicken_h.age);

      // Debacle:
      animal_h = lion_h;
      animal_h.make_sound();
      $display("The animal is %0d years old", animal_h.age);
      
      // Esa pieza del codigo da error:
      // ** Fatal: Generic animals dont have a sound
      // Porque??? Si lion es una clase extendida de animal
      // OK. Pero la variable animal_h esta llamando al metodo make_sound()
      // de animal, no de lion
      // Debemos decirle a SV que use las funciones referenciadas por la variable
      // o por el objeto!!!!


      animal_h = chicken_h;
      animal_h.make_sound();
      $display("The animal is %0d years old", animal_h.age);
      
   end // initial begin

endmodule : top