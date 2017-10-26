// UVM solution to interthread communication
//	Consta de 2 partes:
//		*	Ports-Objects: los instanciamos en nuestros uvm_components para habilitar
//				que run_phase se comunique con otros threads
//		*	TLM Fifos (solo almacenan 1 elemento)

class producer extends uvm_component;
   `uvm_component_utils(producer);

   int shared;
   // uvm_put_port es una clase parametrizada
   // esta clase se encarga de lidear con toda la bola de sincronizacion de 
   // get_it y put_it
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
         $display("Sent %0d", shared);
      end
      phase.drop_objection(this);
   endtask : run_phase
endclass : producer