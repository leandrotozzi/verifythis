// -- EN EL TOP -- top es un modulo, no un uvm_component ---------------------
//   cntxt = null : el ambito arranca en la raiz de UVM
//   inst  = "*"  : visible para todo el arbol de componentes
uvm_config_db #(virtual vtalu_bfm)::set(null, "*", "bfm", bfm);

// -- EN UN COMPONENTE -- siempre dentro de build_phase ----------------------
//   cntxt = this : el ambito es la ruta jerarquica de ESTE componente
//   inst  = ""   : sin sufijo, la ruta es exactamente la del componente
if (!uvm_config_db #(virtual vtalu_bfm)::get(this, "", "bfm", bfm))
  `uvm_fatal("DRIVER", "Failed to get BFM")

// El 3er argumento ("bfm") es el NOMBRE del dato adentro de la base.
// Si el string del set y el del get no son identicos, esto compila igual
// y explota en run time con un null pointer.
