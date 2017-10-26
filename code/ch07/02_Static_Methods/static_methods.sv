// Metodos Statics
virtual class animal;
   protected int age=-1;

   function new(int age);
      set_age(age);
   endfunction : new

   function void set_age(int a);
      age = a;
   endfunction : set_age

   function int get_age();
      if (age == -1)
        $fatal(1, "You didn't set the age.");
      else
        return age;
   endfunction : get_age

   pure virtual function void make_sound();

endclass : animal


class lion extends animal;

   protected string        name;

   function new(int age, string n);
      super.new(age);
      name = n;
   endfunction : new

   function void make_sound();
      $display ("%s says Roar", get_name());
   endfunction : make_sound

   function string get_name();
      return name;
   endfunction : get_name
   
endclass : lion

class lion_cage;

   protected static lion cage[$];

   static function void cage_lion(lion l);
      cage.push_back(l);
   endfunction : cage_lion

   static function void list_lions();
      $display("Lions in cage"); 
      foreach (cage[i])
        $display(cage[i].get_name());
   endfunction : list_lions

endclass : lion_cage

   

module top;


   initial begin
      lion   lion_h;
      lion_h  = new(2,  "Kimba");
      lion_cage::cage_lion(lion_h);
      lion_h  = new(3,  "Simba");
      lion_cage::cage_lion(lion_h);
      lion_h  = new(15, "Mustafa");
      lion_cage::cage_lion(lion_h);
      lion_cage::list_lions();
   end

endmodule : top