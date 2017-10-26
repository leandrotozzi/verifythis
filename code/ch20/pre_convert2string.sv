// Wrong Way de hacer convert2string!
//class animal;
   virtual function string convert2string();
      return $sformatf("Age: %0d", age);
   endfunction : convert2string
//class lion extends animal;
   function string convert2string();
      string gender_s;
      gender_s = (is_female) ? "Female" : "Male";
      return sformat("Age: %0d Gender: ",age, gender_s);
   endfunction : convert2string

//class captive_lion extends lion;
   function string convert2string();
      return {$sformatf("age: %0d is_female: %0b name: %s", 
      	       age, is_female, name) };
   endfunction : convert2string