#!/bin/bash
# The day 7 capstone. It fails until you solve it, and tells you at which stage.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# Unlike the other exercises with a statement, here there is no file with a
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

# --assert is what turns the concurrent properties of stage 5 on. Without the
# flag they compile, they do not run, and everything "passes".
vlt_uvm top --assert --coverage-user -Wno-fatal \
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

# --- Stage 2: the driver -------------------------------------------------------
run_sim +UVM_TESTNAME=smoke_test || falta "smoke_test ended with UVM_ERROR"
for patron in 'WR @0x00' 'RD @0x00' 'WR @0x04' 'RD @0x04' 'RD @0x08' 'RD @0x0c'; do
   grep -qi "$patron" "$VLT_LOG" || falta "in smoke_test there is no transfer
    '$patron'. The directed sequence has to write and read the four
    registers: it is row 1 of the verification plan."
done
echo "STAGE 2 OK: the driver drives the bus and the directed sequence passes"

# --- Stage 3: the scoreboard ---------------------------------------------------
run_sim +UVM_TESTNAME=random_test || falta "random_test ended with UVM_ERROR.
    The DUT is healthy: the one getting it wrong is your model. The four traps are
    together in the 'The fine print' section of spec.md.
    If the errors say [SVA], it is not the scoreboard: your stage 5 properties are
    firing on a legal bus, and that is a false positive."
echo "    ...and now the same test against the DUT with the bug"

# A scoreboard that never saw an error is not tested. +BUG=1 removes the DUT's
# CTRL.EN gate: the accumulator always adds.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=random_test +BUG=1
if ! grep -q 'UVM_ERROR.*\[SCOREBOARD\]' "$VLT_LOG"; then
   falta "with +BUG=1 the DUT accumulates even with CTRL.EN at 0, and your scoreboard
    said nothing. Either it does not model EN, or it never reads ACC: check row 5 of
    the verification plan."
fi
unset UVM_ERRORS_OK
echo "STAGE 3 OK: the scoreboard closes green and catches the +BUG=1 bug"

# --- Stage 4: the coverage ----------------------------------------------------
cov=$(cov_report | tee /dev/stderr | awk '/covergroup/ {print}')
[ -n "$cov" ] || falta "no covergroup coverage was generated. Either the coverage
    component hanging off the analysis port is missing, or the covergroup is never sampled."
puntos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\2/p')
llenos=$(echo "$cov" | sed -n 's/.*(\([0-9]*\)\/\([0-9]*\)).*/\1/p')
if [ "${puntos:-0}" -lt 20 ]; then
   falta "your covergroup has ${puntos:-0} points and the verification plan of
    spec.md has seven rows: with the address-by-direction cross alone, you are already
    over twenty."
fi
if [ "$((llenos * 100 / puntos))" -lt 90 ]; then
   falta "coverage $llenos/$puntos. Look at which bin stayed at zero and write the
    stimulus that fills it -- it is the coverage closure cycle of day 6."
fi
# Rows 8 and 9 of the plan come EMPTY in spec.md, and these are their bins. They
# are asked for by name because the checker reads the coverage database, not your
# code: the name is the contract, the same as the test names. And they are asked
# for FILLED, because a bin that nobody sampled is a row that nobody verified.
# The .dat separates its fields with control bytes; what is readable at the end
# of each line is "<covergroup>.<coverpoint>.<bin>' <count>".
for bin in back_to_back unaligned; do
   cuenta=$(awk -v b=".$bin'" 'index($0, b) {print $NF}' "$VLT_OBJ/coverage.dat" | tail -1)
   [ -n "$cuenta" ] || falta "the covergroup has no '$bin' bin. Rows 8 and 9 of the
    verification plan of spec.md come empty: the spec promises both in one line
    each --PSEL can stay high between two transfers, and PADDR[1:0] is ignored--
    and none of the first seven rows measures them. Fill in the rows and add the
    bins with those two names."
   [ "$cuenta" -gt 0 ] || falta "the '$bin' bin exists and stayed at ZERO: the
    row is in the plan and the stimulus never produced the scenario. A bin nobody
    sampled is a row nobody verified."
done
echo "STAGE 4 OK: coverage $llenos/$puntos, with rows 8 and 9 of the plan measured"

# --- Stage 5: the protocol, checked where it happens --------------------------
# The other half of day 7. The properties go inside apb_if.sv, and there is a
# protocol bug the scoreboard CANNOT see: with +BUG=2 the usual module moves
# PADDR in the middle of ACCESS. The DUT answers at the new address, the monitor
# reconstructs a consistent transfer, and the eight transfers come out tidy. Only
# an assertion notices.
#
# There is nothing to check for false positives here: every run above goes
# through uvm_summary_ok, so a property that fires on a legal bus has already
# turned stage 1 or stage 3 red.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=monitor_test +STIM +BUG=2
unset UVM_ERRORS_OK
sva=$(grep -c 'UVM_ERROR.*\[SVA\]' "$VLT_LOG" || true)
if [ "$sva" -eq 0 ]; then
   falta "with +BUG=2 the usual module moves PADDR in the middle of ACCESS, which the
    protocol forbids, and nothing fired. Either apb_if.sv has no properties yet, or
    the one that is missing is the payload's: while PSEL is up and the transfer has
    not ended, PADDR, PWRITE and PWDATA do not move. Report it with
    \`uvm_error("SVA", ...) in the property's else."
fi
vistas=$(grep -c 'UVM_INFO.*\[MONITOR\]' "$VLT_LOG" || true)
if [ "$vistas" -ne 8 ]; then
   falta "with +BUG=2 your monitor reported $vistas transfers and there are still 8.
    The bug does not change the handshake: that is the whole point of stage 5."
fi
echo "STAGE 5 OK: the assertion catches $sva protocol violations that the monitor"
echo "            saw as 8 clean transfers"

echo
echo "EXERCISE OK: monitor, driver, scoreboard, coverage and the protocol checked"
echo "             where it happens. That is a testbench."
