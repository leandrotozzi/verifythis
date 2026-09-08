// La configuracion del env: las dos interfaces del testbench. Como en el
// seccion Sequences, es una clase pelada y el constructor las exige.
class apb_env_config;

   virtual apb_if bfm;       // la que maneja el testbench
   virtual apb_if stim_bfm;  // la del modulo de siempre: solo se mira

   function new(virtual apb_if bfm, virtual apb_if stim_bfm);
      this.bfm = bfm;
      this.stim_bfm = stim_bfm;
   endfunction : new

endclass : apb_env_config
