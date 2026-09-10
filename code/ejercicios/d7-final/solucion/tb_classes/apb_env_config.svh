// The env configuration: the two interfaces of the testbench. As in the
// Sequences section, it is a plain class and the constructor demands them.
class apb_env_config;

   virtual apb_if bfm;       // the one the testbench drives
   virtual apb_if stim_bfm;  // the legacy module's: only watched

   function new(virtual apb_if bfm, virtual apb_if stim_bfm);
      this.bfm = bfm;
      this.stim_bfm = stim_bfm;
   endfunction : new

endclass : apb_env_config
