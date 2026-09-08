// El config del agent NO es un uvm_object: es una clase pelada. Por eso el
// constructor puede EXIGIR los dos datos, y quien se olvide de uno no compila.
// Un uvm_object se crea con type_id::create(), que solo toma un nombre, y esa
// garantia se pierde.
class vtalu_agent_config;

   virtual vtalu_bfm bfm;

   // protected + getter: nadie lo cambia despues de que el agent se construyo.
   protected uvm_active_passive_enum is_active;

   function new(virtual vtalu_bfm bfm, uvm_active_passive_enum is_active);
      this.bfm = bfm;
      this.is_active = is_active;
   endfunction : new

   function uvm_active_passive_enum get_is_active();
      return is_active;
   endfunction : get_is_active

endclass : vtalu_agent_config
