// The env configuration: the two interfaces of the testbench.
class fifo_env_config;

   virtual fifo_if bfm;       // the one the testbench drives
   virtual fifo_if stim_bfm;  // the legacy module's: only watched

   function new(virtual fifo_if bfm, virtual fifo_if stim_bfm);
      this.bfm = bfm;
      this.stim_bfm = stim_bfm;
   endfunction : new

endclass : fifo_env_config
