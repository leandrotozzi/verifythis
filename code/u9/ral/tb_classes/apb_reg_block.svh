// The register map of spec.md, written as a UVM register model.
//
// The table of the spec maps one to one onto this file, and that is the check
// worth doing out loud: four registers, six fields, four addresses. Nothing here
// knows that the bus is APB -- swap the adapter and the same model drives AHB.
//
// The access string of every field IS the specification. Get it wrong and the
// built-in sequences of the last file catch it; see the +MAL run of run.sh.

// 0x00 -- CTRL. EN is an ordinary bit. CLR is not: writing a 1 clears ACC and
// OVF, and the bit always reads back 0.
class ctrl_reg extends uvm_reg;
   `uvm_object_utils(ctrl_reg)

   rand uvm_reg_field EN;
   rand uvm_reg_field CLR;

   function new(string name = "ctrl_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   // configure(parent, size, lsb_pos, access, volatile, reset, has_reset,
   //           is_rand, individually_accessible)
   virtual function void build();
      EN = uvm_reg_field::type_id::create("EN");
      EN.configure(this, 1, 0, "RW", 0, 'h0, 1, 1, 0);

      // "WC" is the name UVM has for exactly this: the write clears the field,
      // the mirror drops to zero, and the read returns that zero. Modelling it as
      // "RW" is the classic mistake, and it is what +MAL does. "WOC" also passes,
      // for the wrong reason: any WO* access takes the field out of bit_bash and
      // out of do_check, so nobody looks at it. See slides/es/180-ral.md.
      CLR = uvm_reg_field::type_id::create("CLR");
      CLR.configure(this, 1, 1, $test$plusargs("MAL") ? "RW" : "WC", 0, 'h0, 1, 1, 0);
   endfunction : build

endclass : ctrl_reg

// 0x04 -- SCRATCH. A plain RW register. That every write to it also adds to ACC
// is a side effect the model does not know about, and does not need to.
class scratch_reg extends uvm_reg;
   `uvm_object_utils(scratch_reg)

   rand uvm_reg_field VALUE;

   function new(string name = "scratch_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      VALUE = uvm_reg_field::type_id::create("VALUE");
      VALUE.configure(this, 32, 0, "RW", 0, 'h0, 1, 1, 1);
   endfunction : build

endclass : scratch_reg

// 0x08 -- ACC. Read-only, and volatile: the DUT changes it behind the model's
// back, on every write to SCRATCH. See the comment on set_compare() below.
class acc_reg extends uvm_reg;
   `uvm_object_utils(acc_reg)

   uvm_reg_field VALUE;

   function new(string name = "acc_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      VALUE = uvm_reg_field::type_id::create("VALUE");
      VALUE.configure(this, 32, 0, "RO", 1, 'h0, 1, 0, 1);
   endfunction : build

endclass : acc_reg

// 0x0C -- STATUS. Two read-only bits, and both are volatile for the same reason
// as ACC: EN is a copy of CTRL.EN, and OVF turns on when the accumulator
// overflows -- neither of them happens on a write to STATUS.
class status_reg extends uvm_reg;
   `uvm_object_utils(status_reg)

   uvm_reg_field EN;
   uvm_reg_field OVF;

   function new(string name = "status_reg");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction : new

   virtual function void build();
      EN = uvm_reg_field::type_id::create("EN");
      EN.configure(this, 1, 0, "RO", 1, 'h0, 1, 0, 0);
      OVF = uvm_reg_field::type_id::create("OVF");
      OVF.configure(this, 1, 1, "RO", 1, 'h0, 1, 0, 0);
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

   // Not build_phase: a uvm_reg_block is a uvm_object, not a component. Nobody
   // calls this for you -- the test does, right after the create().
   virtual function void build();
      // create_map(name, base_addr, n_bytes, endian, byte_addressing)
      default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN, 1);

      CTRL = ctrl_reg::type_id::create("CTRL");
      CTRL.configure(this, null, "");
      CTRL.build();
      default_map.add_reg(CTRL, CTRL_ADDR, "RW");

      SCRATCH = scratch_reg::type_id::create("SCRATCH");
      SCRATCH.configure(this, null, "");
      SCRATCH.build();
      default_map.add_reg(SCRATCH, SCRATCH_ADDR, "RW");

      ACC = acc_reg::type_id::create("ACC");
      ACC.configure(this, null, "");
      ACC.build();
      default_map.add_reg(ACC, ACC_ADDR, "RO");

      STATUS = status_reg::type_id::create("STATUS");
      STATUS.configure(this, null, "");
      STATUS.build();
      default_map.add_reg(STATUS, STATUS_ADDR, "RO");

      // The honest line of the whole unit. ACC and STATUS have an address, but
      // they are not registers: their value is produced by writes to OTHER
      // addresses. A register model predicts "what I wrote is what I will read",
      // and for these two that sentence is false, so mirror(UVM_CHECK) is turned
      // off on them. Reads still update the mirror -- a read is a prediction --
      // and the accumulator itself stays where it was in the capstone: in the
      // scoreboard, which is the thing that does know how to add.
      ACC.VALUE.set_compare(UVM_NO_CHECK);
      STATUS.EN.set_compare(UVM_NO_CHECK);
      STATUS.OVF.set_compare(UVM_NO_CHECK);

      lock_model();
   endfunction : build

endclass : apb_reg_block
