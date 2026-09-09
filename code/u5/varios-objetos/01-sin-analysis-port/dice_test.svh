class dice_test extends uvm_test;
   `uvm_component_utils(dice_test);

   dice_roller dice_roller_h;
   coverage coverage_h;
   histogram histogram_h;
   average average_h;

   function void build_phase(uvm_phase phase);
      coverage_h = new("coverage_h", this);
      histogram_h = new("histogram_h", this);
      average_h = new("average_h", this);
      dice_roller_h = new("dice_roller_h", this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      int the_roll;
      phase.raise_objection(this);
      // This part needs attention.
      // What belongs here is:
      //	the Observer design pattern
      //	a UVM analysis port
      // Otherwise none of the OOP magic is being used:
      // these are plain functions passing data along
      repeat (20) begin
         the_roll = dice_roller_h.two_dice();
         coverage_h.write(the_roll);
         histogram_h.write(the_roll);
         average_h.write(the_roll);
      end
      phase.drop_objection(this);
   endtask : run_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : dice_test

