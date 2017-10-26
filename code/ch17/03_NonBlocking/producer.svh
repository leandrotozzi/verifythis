class producer extends uvm_component;
   `uvm_component_utils(producer);

   int shared;
   uvm_put_port #(int) put_port_h;

   function void build_phase(uvm_phase phase);
      
      put_port_h = new("put_port_h", this);
   endfunction : build_phase
   
   // El Producer produce un dato cada 17ns
   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      repeat (3) begin
         #17;
         put_port_h.put(++shared);
         $display("%0tns  Sent %0d", $time, shared);
      end
      #17;
      phase.drop_objection(this);
   endtask : run_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

endclass : producer

   