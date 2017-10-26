class captive_lion extends lion;
   string name;

   function new(int age=0, int babies_in_litter = 0,  bit is_female=0, string name="");
      super.new(age,babies_in_litter, is_female);
      this.name = name;
   endfunction : new

   function string convert2string();
      return { super.convert2string(),"\nName: ", name };
   endfunction : convert2string

   // Polimorfismo: do_copy toma como argumento una clase derivada de animal
   // por lo tanto, usamos la clase animal como argumento
   function void do_copy(animal copied_animal);
      captive_lion copied_captive_lion;
      super.do_copy(copied_animal);
      $cast(copied_captive_lion, copied_animal);
      this.name = copied_captive_lion.name;
   endfunction : do_copy
endclass : captive_lion

class circus_lion extends captive_lion;
   byte numb_tricks;

   function new(int age=0, bit is_female=0, int babies_in_litter = 0,
                string name="", byte numb_tricks=0);
      super.new(age,babies_in_litter, is_female, name);
      this.numb_tricks = numb_tricks;
   endfunction : new

   function string convert2string();
      return {super.convert2string(),"\n",
              $sformatf("numb_tricks: %0d",numb_tricks)};
   endfunction : convert2string
   
   //do_copy pasa el argumento a su clase superior
   function void do_copy(animal copied_animal);
      circus_lion copied_circus_lion;
      super.do_copy(copied_animal);
      // Luego casteamos copied_animal a una variable de su tipo de clase
      $cast(copied_circus_lion, copied_animal);
      this.numb_tricks = copied_circus_lion.numb_tricks;
   endfunction : do_copy


endclass : circus_lion