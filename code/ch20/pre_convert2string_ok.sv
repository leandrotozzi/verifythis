//virtual class animal;
   virtual function string convert2string();
      return $sformatf("Age: %0d", age);
   endfunction : convert2string

//class mammal extends animal;

   function string convert2string();
      return {super.convert2string(), 
              $sformatf("\nbabies in litter: %0d",babies_in_litter)};
   endfunction : convert2string

//class lion extends mammal;

   function string convert2string();
      string gender_s;
      gender_s = (is_female) ? "Female" : "Male";
      return {super.convert2string(), "\nGender: ",gender_s};
   endfunction : convert2string