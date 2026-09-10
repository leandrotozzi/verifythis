// ILLUSTRATION -- not compiled. uvm_object_globals.svh:354-364, uvm-core 2020.3.1,
// copied verbatim: code/.uvm/ is downloaded and gitignored, so the slide cannot
// pull the enum straight out of the library.
typedef enum {
   UVM_NO_ACTION = 'b0000000,
   UVM_DISPLAY   = 'b0000001,
   UVM_LOG       = 'b0000010,
   UVM_COUNT     = 'b0000100,
   UVM_EXIT      = 'b0001000,
   UVM_CALL_HOOK = 'b0010000,
   UVM_STOP      = 'b0100000,
   UVM_RM_RECORD = 'b1000000
} uvm_action_type;
