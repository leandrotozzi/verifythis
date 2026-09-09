// UVM solution to interthread communication
//	It has 2 parts:
//		*	Ports-Objects: instantiated in our uvm_components so that
//				run_phase can talk to other threads
//		*	TLM Fifos (they hold only 1 element)

class producer extends uvm_component;
   `uvm_component_utils(producer);

   int shared;
   // uvm_put_port is a parameterized class
   // this class takes care of the whole synchronization mess around
   // get_it and put_it
   uvm_put_port #(int) put_port_h;

   function void build_phase(uvm_phase phase);
      put_port_h = new("put_port_h", this);
   endfunction : build_phase

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      repeat (3) begin
         put_port_h.put(++shared);
         `uvm_info("PRODUCER", $sformatf("Sent %0d", shared), UVM_MEDIUM)
      end
      phase.drop_objection(this);
   endtask : run_phase
endclass : producer
