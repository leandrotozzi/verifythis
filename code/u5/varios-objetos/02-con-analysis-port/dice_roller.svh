// Same as version 01, but publishing: instead of returning the number it writes
// it to an analysis port, and stops knowing who reads it. Unit 15.
class dice_roller extends uvm_component;
   `uvm_component_utils(dice_roller);

   rand byte die1;
   rand byte die2;

   constraint d6 {
      die1 >= 1;
      die1 <= 6;
      die2 >= 1;
      die2 <= 6;
   }

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // cb: port-and-run
   // 1) declare the port, with the data type it will carry
   uvm_analysis_port #(int) roll_ap;

   // 2) instantiate it in build_phase, with new(): ports do not go through the factory
   function void build_phase(uvm_phase phase);
      roll_ap = new("roll_ap", this);
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      int the_roll;
      phase.raise_objection(this);
      void'(randomize());
      repeat (40) begin
         void'(randomize());
         the_roll = die1 + die2;
         // 3) write: the port calls write() on every subscriber
         roll_ap.write(the_roll);
      end
      phase.drop_objection(this);
   endtask : run_phase
   // cb: end

endclass : dice_roller
