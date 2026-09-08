// DPI de UVM para Verilator.
//
// UVM trae src/dpi/uvm_dpi.cc, pero no compila fuera de VCS/Questa/Incisive:
// uvm_hdl.c corta con #error "hdl vendor backend is missing" porque el backdoor
// de acceso jerarquico esta escrito contra el VPI propietario de cada vendor.
//
// Ese backdoor lo usa unicamente el register layer (uvm_reg), que este curso no
// toca en ningun ejemplo. Asi que aca se compila lo que si sirve — regex y
// linea de comandos — y las seis uvm_hdl_* quedan como stubs.
//
// Los tres fuentes de abajo son C compilado como C++, y las declaran los wrappers
// DPI que genera Verilator, que tienen linkage C: de ahi el extern "C" que los
// envuelve. Sin eso el linker no los encuentra.
#include "svdpi.h"
#include <climits>
#include <cstdio>
#include <cstdlib>
#include <cstring>

extern "C" {
#include "uvm_common.c"
#include "uvm_regex.cc"
#include "uvm_svcmd_dpi.c"

// Backdoor del register layer: sin uso en este curso.
int uvm_hdl_check_path(char *path) { return 0; }
int uvm_hdl_read(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_deposit(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_force(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_release_and_read(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_release(char *path) { return 0; }
}
