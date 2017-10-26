// uvm_subscriber:
//    extiende la clase uvm_component y permite conectarte a un analysis port
//    Es una clase parametrizable! 
//    La clase te da algo y requiere algo a cambio
//       * La clase te da un objeto llamado analysis_export
//       * Requiere que crees un metodo write, que maneje el dato

class coverage extends uvm_subscriber#(int);
   `uvm_component_utils(coverage);
   int the_roll;



   covergroup dice_cg;
      coverpoint the_roll{
         bins  twod6[] = {2,3,4,5,6,7,8,9,10,11,12};}
   endgroup


   function new(string name, uvm_component parent = null);
      super.new(name,parent);
      dice_cg = new();
   endfunction : new
   

   function void write (int t);
      the_roll = t;
      dice_cg.sample();
   endfunction : write

   function void report_phase(uvm_phase phase);
     $display("\nCOVERAGE: %2.0f%% ", dice_cg.get_coverage());
   endfunction : report_phase
   
endclass : coverage