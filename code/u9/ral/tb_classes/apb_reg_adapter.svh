// The only class in the unit that knows the bus exists. Twenty lines, and they
// are the whole reason the register model is portable: a generic uvm_reg_bus_op
// in, an apb_transaction out.
//
// Written once per protocol, not once per project. This is the file you would
// get with a commercial APB VIP.
class apb_reg_adapter extends uvm_reg_adapter;
   `uvm_object_utils(apb_reg_adapter)

   function new(string name = "apb_reg_adapter");
      super.new(name);
   endfunction : new

   // Downstream: the model asks for a register access, this builds the bus item
   // the sequencer will hand to the driver.
   virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
      apb_transaction t = apb_transaction::type_id::create("t");
      t.write = (rw.kind == UVM_WRITE);
      t.addr  = rw.addr[7:0];
      t.wdata = rw.data[31:0];
      return t;
   endfunction : reg2bus

   // Upstream: a bus item comes back -- from the driver's response, or from the
   // monitor when prediction is explicit -- and this fills the generic operation
   // the model understands.
   //
   // PSLVERR is what makes status meaningful: an access to an unmapped address
   // comes back UVM_NOT_OK, and the write()/read() call reports it.
   virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      apb_transaction t;
      if (!$cast(t, bus_item)) `uvm_fatal("REG ADAPTER", "Not an apb_transaction")
      rw.kind   = t.write ? UVM_WRITE : UVM_READ;
      rw.addr   = t.addr;
      rw.data   = t.write ? t.wdata : t.rdata;
      rw.status = t.slverr ? UVM_NOT_OK : UVM_IS_OK;
   endfunction : bus2reg

endclass : apb_reg_adapter
