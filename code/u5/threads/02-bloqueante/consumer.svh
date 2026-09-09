class consumer extends uvm_component;
   `uvm_component_utils(consumer);

   // uvm_get_port handles all the interthread coordination
   uvm_get_port #(int) get_port_h;
   int shared;

   function void build_phase(uvm_phase phase);
      get_port_h = new("get_port_h", this);
   endfunction : build_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      forever begin
         get_port_h.get(shared);
         `uvm_info("CONSUMER", $sformatf("Received: %0d", shared), UVM_MEDIUM)
      end
   endtask : run_phase
endclass : consumer

