// El sequencer virtual: no tiene cola, no arbitra items, no habla con ningun
// driver. Es un componente que existe para dos cosas:
//
//   1. tener los HANDLES a los sequencers de verdad, en un lugar que la
//      sequence pueda alcanzar sin buscar por string;
//   2. ser un uvm_component, o sea vivir en el arbol y tener un nombre.
//
// Por eso extiende uvm_sequencer SIN parametrizar: el item por defecto es
// uvm_sequence_item, y nunca se manda ninguno.
class virtual_sequencer extends uvm_sequencer;
   `uvm_component_utils(virtual_sequencer)

   sequencer clase_sequencer_h;
   sequencer modulo_sequencer_h;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : virtual_sequencer
