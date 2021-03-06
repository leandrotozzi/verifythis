// Static Class version

virtual class animal;
   protected int age=-1;
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
        

// Parameterized class
// mediante el parametro T (type) especificamos que
// tipo de queue es.
class animal_cage #(type T);

   protected static T cage[$];

   static function void cage_animal(T l);
      cage.push_back(l);
   endfunction : cage_animal

   static function void list_animals();
      $display("Animals in cage:"); 
      foreach (cage[i])
        $display(cage[i].get_name());
   endfunction : list_animals

endclass : animal_cage

   


module top;

   initial begin
      lion   lion_h;
      chicken  chicken_h;
      lion_h = new(15, "Mustafa");
      animal_cage #(lion)::cage_animal(lion_h);
      lion_h = new(15, "Simba");
      animal_cage #(lion)::cage_animal(lion_h);

      chicken_h = new(1, "Clucker");
      animal_cage #(chicken)::cage_animal(chicken_h);
      chicken_h = new(1, "Scratchy");
      animal_cage #(chicken)::cage_animal(chicken_h);

      $display("-- Lions --");
      animal_cage #(lion)::list_animals();
      $display("-- Chickens --");
      animal_cage #(chicken)::list_animals();
   end

endmodule : top