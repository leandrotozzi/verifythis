// The env configuration: the two interfaces of the testbench.
// Like the agent config, it is a plain class and the constructor demands them.
class env_config;

   virtual vtalu_bfm clase_bfm;
   virtual vtalu_bfm modulo_bfm;

   function new(virtual vtalu_bfm clase_bfm, virtual vtalu_bfm modulo_bfm);
      this.clase_bfm  = clase_bfm;
      this.modulo_bfm = modulo_bfm;
   endfunction : new

endclass : env_config
