// -- IN THE TOP -- top is a module, not a uvm_component ---------------------
//   cntxt = null : the scope starts at the UVM root
//   inst  = "*"  : visible to the whole component tree
uvm_config_db #(virtual vtalu_bfm)::set(null, "*", "bfm", bfm);

// -- IN A COMPONENT -- always inside build_phase ----------------------------
//   cntxt = this : the scope is the hierarchical path of THIS component
//   inst  = ""   : with no suffix, the path is exactly the component's
if (!uvm_config_db #(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
  `uvm_fatal("DRIVER", "Failed to get BFM")

// The 3rd argument ("bfm") is the NAME of the datum inside the database.
// If the string in the set and the one in the get are not identical, this still
// compiles and blows up at run time with a null pointer.
