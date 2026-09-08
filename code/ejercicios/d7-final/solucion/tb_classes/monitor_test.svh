// Etapa 1: el agent pasivo mirando el bus del modulo de siempre. No hay
// sequence, no hay driver que haga nada: solo hay que VER.
class monitor_test extends base_test;
   `uvm_component_utils(monitor_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      // El estimulo no es nuestro y no avisa cuando termina: son ocho
      // transferencias de cuatro o cinco ciclos, y esto son ciento cincuenta.
      #3000;
      phase.drop_objection(this);
   endtask : run_phase

endclass : monitor_test
