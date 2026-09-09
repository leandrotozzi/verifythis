#!/bin/bash
# Day 3 exercise (Reporting section) -- the uvm_error that does say something.
# It fails until you solve it.
#
#   bash run.sh              with your file
#   SOLUCION=1 bash run.sh   with the one in solucion/, to compare
#
# It runs the same testbench THREE times, and each one grades one thing:
#   1. with +VTALU_BUG, the DUT comes out broken -> your uvm_error has to say
#      WHICH operation failed. The checker knows which one it was.
#   2. without the bug and with the usual verbosity -> the PASS must NOT be
#      printed: a thousand lines of PASS in a regression are a thousand lines
#      nobody reads.
#   3. without the bug and with +UVM_VERBOSITY=UVM_HIGH -> now it does, once per
#      comparison.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
intocables
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top --coverage-user -Wno-fatal $INC -f dut.f -f tb.f

falta() { echo "not yet: $1" >&2; exit 1; }
censo() { sed -nE "s/.*\[CHEQUEO\].*$1=([0-9]+).*/\1/p" "$VLT_LOG" | tail -1; }

echo "=== 1) con el DUT roto: el mensaje tiene que decir cuál falló ==="
# The scoreboard has to report: this run is EXPECTED to end with UVM_ERROR.
UVM_ERRORS_OK=1 VTALU_BUG=1 run_sim +UVM_TESTNAME=random_test > /dev/null

fallas=$(censo fallas)
[ -n "$fallas" ] && [ "$fallas" -gt 0 ] ||
  falta "with +VTALU_BUG the checker saw no mismatch: look at the log above"

grep -q 'UVM_ERROR.*\[SCOREBOARD\]' "$VLT_LOG" ||
  falta "the DUT came out broken and your scoreboard did not report a single
    UVM_ERROR. Before making the message better it has to fire."

primera=$(sed -nE 's/.*\[CHEQUEO\].*primera (.*)$/\1/p' "$VLT_LOG" | tail -1)
linea=$(grep -m1 'UVM_ERROR.*\[SCOREBOARD\]' "$VLT_LOG")
echo "    la primera que falló:  $primera"
echo "    lo que tu scoreboard dijo:"
echo "      $linea"

for kv in $primera; do
  valor=${kv#*=}
  case "$linea" in
    *"$valor"*) ;;
    *) falta "your message does not carry the $kv of the operation that failed.
    The log contract is in the README: A and B in two hex digits, the name of the
    operation, and the two results in four hex digits each." ;;
  esac
done

echo "=== 2) sin el bug y con la verbosidad de siempre: el PASS no se imprime ==="
run_sim +UVM_TESTNAME=random_test > /dev/null
comparadas=$(censo comparadas)
[ -n "$comparadas" ] && [ "$comparadas" -gt 0 ] || falta "the checker never got to report"
pass=$(grep -c '\[SCOREBOARD\].*PASS' "$VLT_LOG" || true)
[ "$pass" -eq 0 ] ||
  falta "the PASS came out $pass times with the usual verbosity. It goes at
    UVM_HIGH: in a nightly regression nobody reads a thousand lines of PASS."

echo "=== 3) sin el bug y con +UVM_VERBOSITY=UVM_HIGH: ahora sí, una por comparación ==="
run_sim +UVM_TESTNAME=random_test +UVM_VERBOSITY=UVM_HIGH > /dev/null
pass=$(grep -c '\[SCOREBOARD\].*PASS' "$VLT_LOG" || true)
[ "$pass" -eq "$comparadas" ] ||
  falta "with UVM_HIGH I count $pass PASS and the checker compared $comparadas
    operations. The PASS goes in the else of the same if: one per comparison, and
    with the word PASS in the message."

cov_report
echo "EXERCISE OK: el mismo scoreboard, ahora legible — $comparadas comparaciones, y el log dice cuál falló"
