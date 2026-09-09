// One config per agent: which interface it drives, and whether it drives or only watches.
class apb_agent_config;

   virtual apb_if bfm;

   protected uvm_active_passive_enum is_active;

   function new(virtual apb_if bfm, uvm_active_passive_enum is_active);
      this.bfm = bfm;
      this.is_active = is_active;
   endfunction : new

   function uvm_active_passive_enum get_is_active();
      return is_active;
   endfunction : get_is_active

endclass : apb_agent_config
