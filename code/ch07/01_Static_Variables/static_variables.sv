// Variables Static
virtual class animal;
  protected int age = -1;

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

// Static Variable to handle global var
// Solo tenemos una copia en memoria de una variable static
// sin importar cuantas intancias de la clase tengamos 
// Son como variables globales creadas de una forma controlada

class lion_cage;
  //Queue static
  static lion cage[$];

endclass : lion_cage

module top;
   initial begin
      lion   lion_h;
      lion_h  = new(2,  "Kimba");
      // :: operator
      //----------------
      //   Accedemos a la variable en la clase lion_cage
      //   mencionando la clase y poniendo el operador :: antes de su nombre
      //   Esto le dice al compilador que queremos acceder a una variable static dentro
      //   del namespace de la clase
      lion_cage::cage.push_back(lion_h);
      lion_h  = new(3,  "Simba");
      lion_cage::cage.push_back(lion_h);
      lion_h  = new(15, "Mustafa");

      // clase::variable_static. Inmediatamente sabemos donde esta declarada
      lion_cage::cage.push_back(lion_h);


      $display("Lions in cage"); 
      foreach (lion_cage::cage[i])
        $display(lion_cage::cage[i].get_name());
   end
endmodule : top