// La configuracion del env: las dos interfaces del testbench.
// Como el config del agent, es una clase pelada y el constructor las exige.
class env_config;

   virtual vtalu_bfm clase_bfm;
   virtual vtalu_bfm modulo_bfm;

   function new(virtual vtalu_bfm clase_bfm, virtual vtalu_bfm modulo_bfm);
      this.clase_bfm  = clase_bfm;
      this.modulo_bfm = modulo_bfm;
   endfunction : new

endclass : env_config
