// Day 8 exercise (unit 9, RAL) -- model the register map.
//
// The table is in the capstone spec: ../d7-final/spec.md, section "The register
// map". This file is that table written as a UVM model, and there is
// nothing else to write: the adapter, the predictor and the tests come from
// code/u9/ral/ and are not touched.
//
// Four registers, six fields, four addresses. The checker goes in stages:
//
//   STAGE 1  the map: names, addresses, widths and accesses
//   STAGE 2  the accesses: the two library sequences green
//   STAGE 3  what the model CANNOT predict
//
// The signature you will use six times:
//
//   configure(parent, size, lsb_pos, access, volatile, reset, has_reset,
//             is_rand, individually_accessible)
//
// And the UVM access list is in the LRM 1800.2, the uvm_reg_field table.
// The four you need here are among: RW, RO, WO, WC, W1C, WOC, RC. Careful with the
// WO* family: UVM stops checking a field whose access starts with WO.

class ctrl_reg extends uvm_reg;
   `uvm_object_utils(ctrl_reg)

   rand uvm_reg_field EN;
   rand uvm_reg_field CLR;

   function new(string name = "ctrl_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      // <<< HERE >>>  EN is bit 0 and it is an ordinary bit: written, read, it stays.
      //              CLR is bit 1 and is NOT ordinary: writing a 1 clears ACC and
      //              OVF, and the bit ALWAYS reads back 0. There is a UVM access that
      //              says exactly that; if you pick the obvious one, stage 2 will
      //              tell you.
   endfunction : build

endclass : ctrl_reg

class scratch_reg extends uvm_reg;
   `uvm_object_utils(scratch_reg)

   rand uvm_reg_field VALUE;

   function new(string name = "scratch_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      // <<< HERE >>>  32 free bits. That they also add into ACC is none of the
      //              model's business: that happens at ANOTHER address.
   endfunction : build

endclass : scratch_reg

class acc_reg extends uvm_reg;
   `uvm_object_utils(acc_reg)

   uvm_reg_field VALUE;

   function new(string name = "acc_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      // <<< HERE >>>  Read only. And look at the `volatile` argument: the DUT
      //              changes it from behind, with no transfer to 0x08.
   endfunction : build

endclass : acc_reg

class status_reg extends uvm_reg;
   `uvm_object_utils(status_reg)

   uvm_reg_field EN;
   uvm_reg_field OVF;

   function new(string name = "status_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      // <<< HERE >>>  Two read-only bits, and both volatile for the same
      //              reason as ACC.
   endfunction : build

endclass : status_reg

class apb_reg_block extends uvm_reg_block;
   `uvm_object_utils(apb_reg_block)

   rand ctrl_reg    CTRL;
   rand scratch_reg SCRATCH;
   acc_reg          ACC;
   status_reg       STATUS;

   function new(string name = "apb_reg_block");
      super.new(name, UVM_NO_COVERAGE);
   endfunction : new

   // Careful: this is NOT a build_phase. A uvm_reg_block is a uvm_object, not a
   // component: nobody calls you. Who calls this build() is the test, one line
   // after the create().
   virtual function void build();
      // El mapa: direcciones de byte, 4 bytes por acceso, little endian.
      default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);

      CTRL = ctrl_reg::type_id::create("CTRL");
      CTRL.configure(this, null, "");
      CTRL.build();
      default_map.add_reg(CTRL, CTRL_ADDR, "RW");

      // <<< HERE >>>  The other three, same as CTRL. The addresses are already
      //              localparam in apb_pkg: SCRATCH_ADDR, ACC_ADDR and
      //              STATUS_ADDR.

      // <<< HERE >>>  And the last one, which is what separates a model that works from one
      //              that lies. ACC and STATUS have an address but are NOT
      //              registers: their value is produced by a write to another
      //              address. A model predicts "what I wrote is what I am going to
      //              read", and for these two that is false.
      //
      //              Stage 3 runs a mirror(UVM_CHECK) over STATUS after
      //              turning CTRL.EN on. As it stands, that check fails -- and the
      //              failure is the model's, not the DUT's. Turn it off with
      //              set_compare(UVM_NO_CHECK) on the fields that cannot be
      //              predicted. The accumulator is still checked where it already was:
      //              in the capstone scoreboard.

      lock_model();
   endfunction : build

endclass : apb_reg_block
