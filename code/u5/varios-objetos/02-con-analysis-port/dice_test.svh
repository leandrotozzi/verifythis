// La estructura del ejemplo: instancia los cuatro componentes y CABLEA el
// productor con los tres observadores. El run_phase se fue. Unidad 15.
class dice_test extends uvm_test;
   `uvm_component_utils(dice_test);

   dice_roller dice_roller_h;
   coverage    coverage_h;
   histogram   histogram_h;
   average     average_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   // build_phase: UVM lo llama TOP-DOWN, primero el padre.
   function void build_phase(uvm_phase phase);
      dice_roller_h = new("dice_roller_h", this);
      coverage_h = new("coverage_h", this);
      histogram_h = new("histogram_h", this);
      average_h = new("average_h", this);
   endfunction : build_phase

   // connect_phase: BOTTOM-UP, y siempre port.connect(export).
   function void connect_phase(uvm_phase phase);
      dice_roller_h.roll_ap.connect(coverage_h.analysis_export);
      dice_roller_h.roll_ap.connect(histogram_h.analysis_export);
      dice_roller_h.roll_ap.connect(average_h.analysis_export);
   endfunction : connect_phase

endclass : dice_test
