class dice_test extends uvm_test;
   `uvm_component_utils(dice_test);

   dice_roller dice_roller_h;
   coverage coverage_h;
   histogram histogram_h;
   average average_h;

   function void build_phase(uvm_phase phase);
      coverage_h    = new("coverage_h", this);
      histogram_h   = new("histogram_h",this);
      average_h     = new("average_h",this);
      dice_roller_h = new("dice_roller_h",this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      int the_roll;
      phase.raise_objection(this);
      // Esta parte necesita atencion. 
      // Aca debemos utilizar:
      //	Observer design pattern
      //	UVM analysis port
      // Sino no estamos haciendo uso de la magia de OOP
      // son simples funciones que se van pasando datos
      repeat (20) begin
         the_roll = dice_roller_h.two_dice();
         coverage_h.write(the_roll);
         histogram_h.write(the_roll);
         average_h.write(the_roll);
      end
      phase.drop_objection(this);
   endtask : run_phase
   
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new
   
endclass : dice_test

