class dice_roller extends uvm_component;
   `uvm_component_utils(dice_roller);
   uvm_analysis_port #(int) roll_ap;

   function void build_phase (uvm_phase phase); 
      roll_ap = new("roll_ap",this); 
   endfunction : build_phase