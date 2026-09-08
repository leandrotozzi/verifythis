// Igual que la version 01, pero publicando: en vez de devolver el numero lo
// escribe en un analysis port, y deja de saber quien lo lee. Unidad 15.
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

   // 1) declarar el port, con el tipo de dato que va a transportar
   uvm_analysis_port #(int) roll_ap;

   // 2) instanciarlo en build_phase, con new(): los ports no van por la factory
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
         // 3) escribir: el port llama al write() de todos los subscribers
         roll_ap.write(the_roll);
      end
      phase.drop_objection(this);
   endtask : run_phase

endclass : dice_roller
