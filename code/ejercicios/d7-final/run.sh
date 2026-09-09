#!/bin/bash
# The day 7 capstone. It fails until you solve it, and tells you at which stage.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# Unlike the other fourteen exercises, here there is no file with a
# hole: there is a DUT, a spec and nothing else. The checker goes in stages and each
# one prints its STAGE N OK, so it can be finished one stage at a time.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

PFX=${SOLUCION:+solucion/}

falta() { echo; echo "not yet: $1" >&2; exit 1; }

for f in apb_if.sv apb_pkg.sv; do
   [ -f "$PFX$f" ] && continue
   falta "$PFX$f does not exist. Start there: the interface with the pins of
    spec.md and the package that includes your classes. The list of deliverables, in
    order, is in the README."
done

vlt_uvm top --coverage-user -Wno-fatal \
   +incdir+"${PFX}tb_classes" \
   rtl/apb_regs.sv "${PFX}apb_pkg.sv" "${PFX}apb_if.sv" apb_stim_module.sv top.sv

# --- Stage 1: the monitor -----------------------------------------------------
# The usual module does EIGHT transfers and your monitor has to see them
# all. No driver, no scoreboard, no coverage: just watching.
run_sim +UVM_TESTNAME=monitor_test +STIM || falta "monitor_test did not reach the end"
vistas=$(grep -c 'UVM_INFO.*\[MONITOR\]' "$VLT_LOG" || true)
if [ "$vistas" -ne 8 ]; then
   falta "your monitor reported $vistas transfers and the usual module does 8.
    If it is 0, check that the agent of the stim_bfm bus is PASSIVE and that the monitor
    hooks itself up (bfm.monitor_h = this in the build_phase). If it is more than 8,
    you are reporting cycles instead of transfers: a transfer ends
    on the edge where PREADY is high, and a read lasts two."
fi
echo "STAGE 1 OK: the monitor sees the 8 transfers of the usual module"

# --- Etapa 2: el driver -------------------------------------------------------
run_sim +UVM_TESTNAME=smoke_test || falta "smoke_test ended with UVM_ERROR"
for patron in 'WR @0x00' 'RD @0x00' 'WR @0x04' 'RD @0x04' 'RD @0x08' 'RD @0x0c'; do
   grep -qi "$patron" "$VLT_LOG" || falta "in smoke_test there is no transfer
    '$patron'. The directed sequence has to write and read the four
    registers: it is row 1 of the verification plan."
done
echo "STAGE 2 OK: the driver drives the bus and the directed sequence passes"

# --- Etapa 3: el scoreboard ---------------------------------------------------
run_sim +UVM_TESTNAME=random_test || falta "random_test ended with UVM_ERROR.
    The DUT is healthy: the one getting it wrong is your model. The four traps are
    together in the 'The fine print' section of spec.md."
echo "    ...and now the same test against the DUT with the bug"

# A scoreboard that never saw an error is not tested. +BUG=1 removes the DUT's
# CTRL.EN gate: the accumulator always adds.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=random_test +BUG=1
if ! grep -q 'UVM_ERROR.*\[SCOREBOARD\]' "$VLT_LOG"; then
   falta "with +BUG=1 the DUT accumulates even with CTRL.EN at 0, and your scoreboard
    said nothing. Either it does not model EN, or it never reads ACC: check row 5 of the
    verificacion."
fi
unset UVM_ERRORS_OK
echo "STAGE 3 OK: the scoreboard closes green and catches the +BUG=1 bug"

# --- Etapa 4: la cobertura ----------------------------------------------------
cov=$(cov_report | tee /dev/stderr | awk '/covergroup/ {print}')
[ -n "$cov" ] || falta "no covergroup coverage was generated. Either the coverage
    component hanging off the analysis port is missing, or the covergroup is never sampled."
puntos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\2/p')
llenos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\1/p')
if [ "${puntos:-0}" -lt 20 ]; then
   falta "your covergroup has ${puntos:-0} points and the verification plan of
    spec.md has seven rows: with the address-by-direction cross alone, you already
    son mas de veinte."
fi
if [ "$((llenos * 100 / puntos))" -lt 90 ]; then
   falta "coverage $llenos/$puntos. Look at which bin stayed at zero and write the
    stimulus that fills it -- it is the coverage closure cycle of day 6."
fi
echo "STAGE 4 OK: cobertura $llenos/$puntos"

echo
echo "EXERCISE OK: monitor, driver, scoreboard y cobertura. Eso es un testbench."
