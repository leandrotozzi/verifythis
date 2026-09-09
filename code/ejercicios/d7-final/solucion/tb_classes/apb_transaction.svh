// One APB transfer, whole: the request and the response in the same
// object. That works because APB has no overlapping transactions -- in AXI this
// would be two classes and an ID to pair them.
class apb_transaction extends uvm_sequence_item;
   `uvm_object_utils(apb_transaction)

   rand bit        write;
   rand bit [ 7:0] addr;
   rand bit [31:0] wdata;

   // The response: it is not rand. The driver writes it when it comes back from the bus, and
   // the monitor writes it when it sees it go by.
   bit [31:0]      rdata;
   bit             slverr;

   // The addresses are listed one by one and all aligned, instead of putting
   // a range and asking for addr[1:0]==0 separately: Verilator does not combine a dist with
   // another constraint on the same variable, and it warns with UNSATCONSTR --
   // noisy, but it warns. See docs/verilator.md.
   // One in six falls outside the map: without that the unmapped bin of the
   // verification plan never fills.
   constraint c_addr {
      addr dist {
         CTRL_ADDR :/ 3, SCRATCH_ADDR :/ 3, ACC_ADDR :/ 2, STATUS_ADDR :/ 2,
         8'h10 :/ 1, 8'h14 :/ 1
      };
   }

   // Half of the writes to CTRL turn EN on, and one in four asks for
   // CLR. Without biasing this, EN=1 comes up in half the cases anyway, but CLR
   // -- which is one loose bit out of 32 -- never comes up.
   constraint c_ctrl {
      (addr == CTRL_ADDR && write) -> wdata inside {32'h0, 32'h1, 32'h2, 32'h3};
   }

   function new(string name = "");
      super.new(name);
   endfunction : new

   // The format is the contract with the checker. See the README.
   function string convert2string();
      return $sformatf("%s @0x%02h = 0x%08h  slverr=%0d", write ? "WR" : "RD", addr,
                       write ? wdata : rdata, slverr);
   endfunction : convert2string

   function void do_copy(uvm_object rhs);
      apb_transaction copiada;
      if (rhs == null) `uvm_fatal("APB TRANSACTION", "Tried to copy from a null pointer")
      if (!$cast(copiada, rhs)) `uvm_fatal("APB TRANSACTION", "Tried to copy wrong type.")
      super.do_copy(rhs);
      write  = copiada.write;
      addr   = copiada.addr;
      wdata  = copiada.wdata;
      rdata  = copiada.rdata;
      slverr = copiada.slverr;
   endfunction : do_copy

endclass : apb_transaction
