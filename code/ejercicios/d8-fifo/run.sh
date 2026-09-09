#!/bin/bash
# The SECOND capstone: a FIFO with backpressure. It fails until you solve it,
# and tells you at which stage.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# It is d7-final's sibling and comes after it. What changes is not the
# protocol -- this one is simpler -- but the SCOREBOARD: the APB one could be
# an address/value table, and this one cannot. A FIFO has order and occupancy,
# and both have to be modelled.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

PFX=${SOLUCION:+solucion/}

falta() { echo; echo "not yet: $1" >&2; exit 1; }

for f in fifo_if.sv fifo_pkg.sv; do
   [ -f "$PFX$f" ] && continue
   falta "$PFX$f does not exist. Start there: the interface with the pins of
    spec.md and the package that includes your classes. The list of deliverables, in
    order, is in the README."
done

vlt_uvm top --coverage-user -Wno-fatal \
   +incdir+"${PFX}tb_classes" \
   rtl/sync_fifo.sv "${PFX}fifo_pkg.sv" "${PFX}fifo_if.sv" fifo_stim_module.sv top.sv

# --- Stage 1: the monitor -----------------------------------------------------
# The usual module does TWELVE cycles with activity and your monitor has to
# see them all. No driver, no scoreboard, no coverage: just watching.
run_sim +UVM_TESTNAME=monitor_test +STIM || falta "monitor_test did not reach the end"
vistos=$(grep -c 'UVM_INFO.*\[MONITOR\]' "$VLT_LOG" || true)
if [ "$vistos" -ne 12 ]; then
   falta "your monitor reported $vistos cycles with activity and the usual module
    does 12. If it is 0, check that the stim_bfm agent is PASSIVE and that the
    monitor hooks itself up (bfm.monitor_h = this in the build_phase). If it is
    many more, you are publishing EVERY edge: a cycle with neither wr_en nor rd_en
    is not activity."
fi
echo "STAGE 1 OK: the monitor sees the 12 cycles of the usual module"

# --- Stage 2: the driver -------------------------------------------------------
run_sim +UVM_TESTNAME=smoke_test || falta "smoke_test ended with UVM_ERROR"
if ! grep -qi 'full=1' "$VLT_LOG"; then
   falta "in smoke_test the FIFO never reached full=1. The directed sequence has
    to fill it to the brim and overshoot: it is row 2 of the verification plan,
    and it is where half the spec lives."
fi
if ! grep -qi 'empty=1' "$VLT_LOG"; then
   falta "in smoke_test the FIFO never reached empty=1. After filling it you have
    to drain it, and read one time too many."
fi
echo "STAGE 2 OK: the driver drives the FIFO and touches both edges"

# --- Stage 3: the scoreboard ---------------------------------------------------
run_sim +UVM_TESTNAME=random_test || falta "random_test ended with UVM_ERROR.
    The DUT is healthy: the one getting it wrong is your model. The four traps are
    together in the 'The fine print' section of spec.md."
echo "    ...and now the same test against the DUT with the bug"

# A scoreboard that never saw an error is not tested. +BUG=1 shifts almost_full
# by one: the DUT keeps delivering the data in order, so a scoreboard
# that only compares DATA passes green and sees nothing.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=random_test +BUG=1
if ! grep -q 'UVM_ERROR.*\[SCOREBOARD\]' "$VLT_LOG"; then
   falta "with +BUG=1 almost_full goes up one place late, and your scoreboard said
    nothing. The data still comes out right: if you only compare what comes out on
    rd_data, this bug is never visible. A FIFO scoreboard has to
    predict the FLAGS, and for that the occupancy has to be modelled."
fi
unset UVM_ERRORS_OK
echo "STAGE 3 OK: the scoreboard closes green and catches the almost_full bug"

# --- Stage 4: the coverage ----------------------------------------------------
cov=$(cov_report | tee /dev/stderr | awk '/covergroup/ {print}')
[ -n "$cov" ] || falta "no covergroup coverage was generated. Either the coverage
    component hanging off the analysis port is missing, or the covergroup is never sampled."
puntos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\2/p')
llenos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\1/p')
if [ "${puntos:-0}" -lt 20 ]; then
   falta "your covergroup has ${puntos:-0} points and the verification plan of
    spec.md has seven rows: with the request-by-occupancy cross alone, you are already
    over twenty."
fi
if [ "$((llenos * 100 / puntos))" -lt 90 ]; then
   falta "coverage $llenos/$puntos. Look at which bin stayed at zero: it is almost always
    'write with the FIFO full' or 'read with the FIFO empty', and both get
    filled by biasing the transaction dist, not by adding cycles."
fi
echo "STAGE 4 OK: coverage $llenos/$puntos"

echo
echo "EXERCISE OK: monitor, driver, stateful scoreboard and coverage."
echo "That scoreboard could not be a table. That is what separates this one from the other."
