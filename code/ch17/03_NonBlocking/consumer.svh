class consumer extends uvm_component;
   `uvm_component_utils(consumer);

   uvm_get_port #(int) get_port_h;
   virtual clk_bfm clk_bfm_i;
   int shared;

   function void build_phase(uvm_phase phase);
      get_port_h = new("get_port_h", this);
      clk_bfm_i  = example_pkg::clk_bfm_i;
   endfunction : build_phase

   // Consumer y producer trabajan a Clocks distintos
   // Consumer tiene el primer flanco positivo a los 7ns 
   //    y luego revisa el dato cada 14ns debido a que usa bfm.clk (= 14ns)
   // Producer produce un dato cada 17ns
   task run_phase(uvm_phase phase);
      forever begin
         @(posedge clk_bfm_i.clk);
         if(get_port_h.try_get(shared))
           $display("%0tns  Received: %0d", $time,shared);
      end
   endtask : run_phase


   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : consumer

   