// ILLUSTRATION -- not compiled. uvm_object_globals.svh:382-390, uvm-core 2020.3.1,
// copied verbatim: code/.uvm/ is downloaded and gitignored, so the slide cannot
// pull the enum straight out of the library.
typedef enum {
   UVM_NONE   = 0,
   UVM_LOW    = 100,
   UVM_MEDIUM = 200,  // the default: with nothing set, UVM_MEDIUM is what you get
   UVM_HIGH   = 300,
   UVM_FULL   = 400,
   UVM_DEBUG  = 500
} uvm_verbosity;

// Any message above the verbosity that was set does not get printed
