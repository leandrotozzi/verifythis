// The hook itself. A callback is NOT a component: it does not live in the tree
// and it has no phases. It is an object that hangs off a component, and the
// component decides where -- and whether -- it gets called.
//
// The base class is empty on purpose: a testbench with no callbacks registered
// runs exactly as it did before, at the cost of one empty virtual call.
typedef class driver;

class driver_callback extends uvm_callback;
   `uvm_object_utils(driver_callback)

   function new(string name = "driver_callback");
      super.new(name);
   endfunction : new

   // A task, not a function: a callback that only edits the transaction could
   // be a function, but one that adds delay needs to consume time. Making the
   // hook a task costs nothing and leaves both open.
   virtual task pre_send(driver drv, command_transaction cmd);
   endtask : pre_send

endclass : driver_callback

// --------------------------------------------------------------------------
// Error injection: flip one bit of A, once every `cada` transactions.
//
// This is the classic use -- and the reason it is worth showing is what it does
// NOT do to the scoreboard. See run.sh.
class flip_bit_cb extends driver_callback;
   `uvm_object_utils(flip_bit_cb)

   int unsigned cada = 8;   // one out of every N
   int unsigned vistas;

   function new(string name = "flip_bit_cb");
      super.new(name);
   endfunction : new

   virtual task pre_send(driver drv, command_transaction cmd);
      vistas++;
      if (vistas % cada != 0) return;
      `uvm_info("FLIP_BIT_CB", $sformatf("A: %02h -> %02h", cmd.A, cmd.A ^ 8'h01),
                UVM_MEDIUM)
      cmd.A ^= 8'h01;
   endtask : pre_send

endclass : flip_bit_cb

// --------------------------------------------------------------------------
// Timing injection: hold the bus idle for a couple of clocks before driving.
//
// It is here to make one point that the factory cannot make: callbacks STACK.
// Both of these are registered on the same driver, and both run, in the order
// they were added. A factory override picks one class and only one.
class jitter_cb extends driver_callback;
   `uvm_object_utils(jitter_cb)

   int unsigned ciclos = 2;

   function new(string name = "jitter_cb");
      super.new(name);
   endfunction : new

   virtual task pre_send(driver drv, command_transaction cmd);
      repeat (ciclos) @(posedge drv.bfm.clk);
   endtask : pre_send

endclass : jitter_cb
