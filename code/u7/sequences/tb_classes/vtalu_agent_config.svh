// The agent config is NOT a uvm_object: it is a plain class. That is why the
// constructor can DEMAND both values, and whoever forgets one does not compile.
// A uvm_object is built with type_id::create(), which only takes a name, and
// that guarantee is lost.
class vtalu_agent_config;

   virtual vtalu_bfm bfm;

   // protected + getter: nobody changes it after the agent was built.
   protected uvm_active_passive_enum is_active;

   function new(virtual vtalu_bfm bfm, uvm_active_passive_enum is_active);
      this.bfm = bfm;
      this.is_active = is_active;
   endfunction : new

   function uvm_active_passive_enum get_is_active();
      return is_active;
   endfunction : get_is_active

endclass : vtalu_agent_config
