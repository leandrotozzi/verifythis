// The directed sequence: it writes and reads the four registers, goes through the three
// traps of the spec and ends with a CLR. Thirteen transfers, none of them
// random -- if something fails here, it fails every time.
class smoke_sequence extends uvm_sequence #(apb_transaction);
   `uvm_object_utils(smoke_sequence)

   function new(string name = "smoke_sequence");
      super.new(name);
   endfunction : new

   task automatic uno(input bit write, input bit [7:0] addr, input bit [31:0] wdata = 32'h0);
      apb_transaction t;
      t = apb_transaction::type_id::create("t");
      start_item(t);
      t.write = write;
      t.addr  = addr;
      t.wdata = wdata;
      finish_item(t);
   endtask : uno

   task body();
      uno(1, CTRL_ADDR, 32'h1);              // EN = 1
      uno(0, CTRL_ADDR);                     // CLR se lee 0, EN se lee 1
      uno(1, SCRATCH_ADDR, 32'h1000_0000);   // ACC = 0x1000_0000
      uno(0, SCRATCH_ADDR);
      uno(0, ACC_ADDR);
      uno(0, STATUS_ADDR);
      uno(1, ACC_ADDR, 32'hFFFF_FFFF);       // RO: se ignora y NO da error
      uno(1, STATUS_ADDR, 32'hFFFF_FFFF);    // idem
      uno(0, ACC_ADDR);                      // sigue valiendo 0x1000_0000
      uno(1, 8'h10, 32'hDEAD_BEEF);          // outside the map: PSLVERR
      uno(0, 8'h10);                         // idem, y PRDATA en cero
      uno(1, CTRL_ADDR, 32'h2);              // CLR
      uno(0, ACC_ADDR);                      // 0
   endtask : body

endclass : smoke_sequence
