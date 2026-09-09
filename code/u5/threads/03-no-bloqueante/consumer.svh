class consumer extends uvm_component;
   `uvm_component_utils(consumer);

   uvm_get_port #(int) get_port_h;
   virtual clk_bfm clk_bfm_i;
   int shared;

   function void build_phase(uvm_phase phase);
      get_port_h = new("get_port_h", this);
      clk_bfm_i = example_pkg::clk_bfm_i;
   endfunction : build_phase

   // Consumer and producer run on different clocks
   // The consumer has its first positive edge at 7ns
   //    and then checks the data every 14ns, because it uses bfm.clk (= 14ns)
   // The producer produces one datum every 17ns
   task run_phase(uvm_phase phase);
      forever begin
         @(posedge clk_bfm_i.clk);
         if (get_port_h.try_get(shared))
            `uvm_info("CONSUMER", $sformatf("Received: %0d", shared), UVM_MEDIUM)
      end
   endtask : run_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : consumer

