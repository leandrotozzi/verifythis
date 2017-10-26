/*
  Definir e instanciar UVM Components:
    1) Extender la clase uvm_components o un derivado de la misma (uvm_tester x ej)
    2) Hay que registrar la clase en la factory con `uvm_component_utils
    3) Constructor minimo: 2 argumentos (string name, uvm_component parent)
        y primer linea debe ser: super.new(name, parent)
    4) Hay que redefinir los metodos de uvm phase
        Son varios metodos y UVM los va llamando en orden

*/

  // 1) ------------------------------------------------------
class scoreboard extends uvm_component;
  // 2) ------------------------------------------------------
  `uvm_component_utils(scoreboard);
  //----------------------------------------------------------

  virtual tinyalu_bfm bfm;

  //3)--------------------------------------------------------
  function new (string name, uvm_component parent);
      super.new(name, parent);
  endfunction : new
  //----------------------------------------------------------


  // 4) Override build_phase: donde se instancian todos los uvm_components
  //    antes el objeto uvm_test pasaba la BFM a los demas objetos. Muy pedorro
  //    Eso fuerza a que tengamos que recibir la BFM con el solo objetivo de pasarla
  //    Es mejor hacer la clase autosuficiente 
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*","bfm", bfm))
          $fatal("Failed to get BFM");
  endfunction : build_phase

  // 4) Override run_phase. 
  //    Todos los demas metodos de uvm_phase son functions.
  //    run_phase es una task. Es el unico que puede consumir tiempo
  //    UVM lanza run_phase en un thread cuando inicia la simulacion
  task run_phase(uvm_phase phase);
      shortint predicted_result;
      forever begin : self_checker
         @(posedge bfm.done) 
	         #1;
           case (bfm.op_set)
             add_op: predicted_result = bfm.A + bfm.B;
             and_op: predicted_result = bfm.A & bfm.B;
             xor_op: predicted_result = bfm.A ^ bfm.B;
             mul_op: predicted_result = bfm.A * bfm.B;
           endcase // case (op_set)
         
         if ((bfm.op_set != no_op) && (bfm.op_set != rst_op))
           if (predicted_result != bfm.result)
             $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                     bfm.A, bfm.B, bfm.op_set.name(), bfm.result);
      end : self_checker
   endtask : run_phase
endclass : scoreboard