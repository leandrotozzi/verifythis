// UVM DPI for Verilator.
//
// UVM ships src/dpi/uvm_dpi.cc, but it does not compile outside VCS/Questa/Incisive:
// uvm_hdl.c stops with #error "hdl vendor backend is missing" because the
// hierarchical-access backdoor is written against each vendor's proprietary VPI.
//
// That backdoor is used only by the register layer (uvm_reg), which this course
// does not touch in any example. So what gets compiled here is what is actually
// useful — regex and command line — and the six uvm_hdl_* stay as stubs.
//
// The three sources below are C compiled as C++, and they are declared by the DPI
// wrappers Verilator generates, which have C linkage: hence the extern "C" that
// wraps them. Without it the linker does not find them.
#include "svdpi.h"
#include <climits>
#include <cstdio>
#include <cstdlib>
#include <cstring>

extern "C" {
#include "uvm_common.c"
#include "uvm_regex.cc"
#include "uvm_svcmd_dpi.c"

// Register layer backdoor: unused in this course.
int uvm_hdl_check_path(char *path) { return 0; }
int uvm_hdl_read(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_deposit(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_force(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_release_and_read(char *path, p_vpi_vecval value) { return 0; }
int uvm_hdl_release(char *path) { return 0; }
}
