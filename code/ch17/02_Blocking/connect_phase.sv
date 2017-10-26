   // Connection Phase
   function void connect_phase(uvm_phase phase);
      producer_h.put_port_h.connect(fifo_h.put_export);
      consumer_h.get_port_h.connect(fifo_h.get_export);
   endfunction : connect_phase