#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
#
# RAL over the capstone's APB. The day 7 testbench is NOT touched: the interface,
# the transaction, the driver, the monitor and the agent come from d7-final/solucion/
# through +incdir, just like in the exercises. This unit adds three files.
#
#   ral_test            write/read/mirror through the model, with explicit prediction
#   builtin_test        uvm_reg_hw_reset_seq and uvm_reg_bit_bash_seq
#   builtin_test +MAL   the same, with CTRL.CLR modelled as "RW" instead of "WOC"
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

CAP=../../ejercicios/d7-final

# -Wno-WIDTHEXPAND: uvm_reg_data_t is 64 bits, so a 32-bit literal --the
# 'h1000_0000 of a write()-- gets widened and Verilator warns about it. It is library
# noise, not the example's.
vlt_uvm top -Wno-fatal -Wno-WIDTHEXPAND \
  +incdir+tb_classes +incdir+"$CAP/solucion/tb_classes" \
  "$CAP/rtl/apb_regs.sv" "$CAP/solucion/apb_pkg.sv" "$CAP/solucion/apb_if.sv" \
  ral_pkg.sv top.sv

run_sim +UVM_TESTNAME=ral_test

# The two library sequences do 380 transfers, and the capstone monitor
# reports every one. UVM_LOW keeps the errors and drops the diary.
run_sim +UVM_TESTNAME=builtin_test +UVM_VERBOSITY=UVM_LOW

# The punchline: a single word wrong in the model, and a sequence nobody wrote
# catches it. Here the UVM_ERROR are the result, not a failure, so run_sim does
# not have to abort.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=builtin_test +UVM_VERBOSITY=UVM_LOW +MAL
unset UVM_ERRORS_OK

# From the Report Summary, which is where UVM really counts. The good runs were
# already checked by run_sim: had they errored, the script would have aborted already.
errores=$(awk '$1 == "UVM_ERROR" && $2 == ":" { print $3 }' "$VLT_LOG")
if [ "${errores:-0}" -eq 0 ]; then
  echo "FAIL: with +MAL the model declares CTRL.CLR as RW and bit_bash should" >&2
  echo "      catch it. If it does not scream, the sequence is not running." >&2
  exit 1
fi

echo
echo "=== the model is the spec ==="
echo "    CTRL.CLR como \"WOC\"  0 UVM_ERROR"
echo "    CTRL.CLR as \"RW\"    $errores UVM_ERROR, from uvm_reg_bit_bash_seq"
grep -m1 'UVM_ERROR.*uvm_reg_bit_bash_seq' "$VLT_LOG" | sed 's/.*\] //; s/^/    > /'
echo
echo "    Nobody wrote a test for CTRL. The sequence generated it from the model, and"
echo "    the only datum it used was the word that says how the field is accessed."
