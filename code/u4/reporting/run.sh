#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
#
# --coverage-user: measures the covergroups and leaves out line/toggle/branch,
# which are not the topic. The number comes out at the end, with cov_report.
#
# -Wno-fatal: the examples have sloppy widths on purpose (WIDTHEXPAND/WIDTHTRUNC)
# and by default any warning stops the build. They still get printed.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

# The scoreboard of this section adds wrong ON PURPOSE: it is the example
# reporting is taught with. Without this opt-out, run_sim would fail on the uvm_error
# the section wants to show.
export UVM_ERRORS_OK=1
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim +UVM_TESTNAME=random_test
unset UVM_ERRORS_OK

# ...but "toleramos los uvm_error" no puede querer decir "no miramos nada". Sin
# esto, un scoreboard desconectado --el analysis port sin conectar, el write()
# que no se llama nunca-- deja el ejemplo igual de verde que ahora, y lo que la
# seccion viene a mostrar no aparece por ningun lado.
if ! grep -q 'UVM_ERROR.*\[SCOREBOARD\]' "$VLT_LOG"; then
   echo "EXPECTED the deliberately broken scoreboard to report [SCOREBOARD]" >&2
   exit 1
fi
cov_report
