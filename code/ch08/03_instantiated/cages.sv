virtual class animal;
   protected int age = -1;
   protected string name;

   function new(int a, string n);
      age = a;
      name = n;
   endfunction : new

   function int get_age();
        return age;
   endfunction : get_age

   function string get_name();
      return name;
   endfunction : get_name

   pure virtual function void make_sound();

endclass : animal



class lion extends animal;

   protected string        name;

   function new(int age, string n);
      super.new(age, n);
   endfunction : new

   function void make_sound();
      $display ("The lion, %s, says Roar", get_name());
   endfunction : make_sound


endclass : lion



class chicken extends animal;

   function new(int age, string n);
      super.new(age, n);
   endfunction : new

   function void make_sound();
      $display ("The Chicken, %s, says BECAWW", get_name());
   endfunction : make_sound

endclass : chicken


// animal_cage no es estatica ahora
class animal_cage #(type T);

   protected T cage[$];

   function void cage_animal(T l);
      cage.push_back(l);
   endfunction : cage_animal

   function void list_animals();
      $display("Animals in cage:"); 
      foreach (cage[i])
        $display(cage[i].get_name());
   endfunction : list_animals

endclass : animal_cage

  

module top;
   
   // Como animal_cage no es estatica, debemos instanciarla
   // el parametro es un tipo de variable
   // Si usamos como parametro un tipo que no tiene el 
   // metodo get_name() hay error de sintaxis
   lion   lion_h;
   chicken  chicken_h;

   animal_cage #(lion)  lion_cage;
   animal_cage #(chicken) chicken_cage;
  
   

   initial begin
      lion_cage = new();
      lion_h = new(15, "Mustafa");
      lion_cage.cage_animal(lion_h);
      lion_h = new(15, "Simba");
      lion_cage.cage_animal(lion_h);

      chicken_cage = new();
      chicken_h = new(1, "Little Red Hen");
      chicken_cage.cage_animal(chicken_h);

      chicken_h = new(1, "Lady Clucksalot");
      chicken_cage.cage_animal(chicken_h);
   

      $display("-- Lions --");
      lion_cage.list_animals();
      $display("-- Chickens --");
      chicken_cage.list_animals();
   end

endmodule : top