#!/bin/bash
# Day 7 exercise (unit 9, RAL). It fails until you solve it, and tells you
# at which stage.
#
#   bash run.sh              with your file
#   SOLUCION=1 bash run.sh   with the one in solucion/, to compare
#
# The testbench is the whole one from code/u9/ral/: the adapter, the predictor and the three
# tests come from there. A single file comes from here -- the register model.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

U9=../../u9/ral
CAP=../d7-final

falta() { echo; echo "not yet: $1" >&2; exit 1; }

# This directory's +incdir goes FIRST: your apb_reg_block.svh beats the unit's.
# With SOLUCION=1, the one in solucion/ wins.
vlt_uvm top -Wno-fatal -Wno-WIDTHEXPAND \
  ${SOLUCION:++incdir+solucion} +incdir+. \
  +incdir+"$U9/tb_classes" +incdir+"$CAP/solucion/tb_classes" \
  "$CAP/rtl/apb_regs.sv" "$CAP/solucion/apb_pkg.sv" "$CAP/solucion/apb_if.sv" \
  "$U9/ral_pkg.sv" "$U9/top.sv"

# --- Stage 1: the map ---------------------------------------------------------
# Not one transfer yet: the model gets printed and compared against the table
# in spec.md. A wrong offset or a wrong access shows up here, before simulating anything.
export UVM_ERRORS_OK=1
run_sim +UVM_TESTNAME=mapa_test > /dev/null || true
unset UVM_ERRORS_OK

grep -o '\[MAPA\].*' "$VLT_LOG" | sed 's/^/    /' || true
falta_campo() {
  grep -Eq "\[MAPA\] +$1" "$VLT_LOG" ||
    falta "$2 does not show up in the model.
    The table is in $CAP/spec.md, section 'The register map'. The model prints
    itself: +UVM_TESTNAME=mapa_test, and compare it line by line."
}
falta_campo 'CTRL +@0x0 +\w+ +\[0\+:1\] +RW'      'CTRL.EN: bit 0, one bit, RW'
falta_campo 'CTRL +@0x0 +\w+ +\[1\+:1\] +(WC|W1C)' 'CTRL.CLR: bit 1, one bit, and an access
    that says "it gets written, it clears, and then it reads back zero". It is not RW. And it is
    not WO nor WOC either: any WO* access takes the field out of bit_bash and out of the do_check
    mask, so both stages would go green without ever looking at the bit'
falta_campo 'SCRATCH +@0x4 +\w+ +\[0\+:32\] +RW'  'SCRATCH: 32 bits at 0x04, RW'
falta_campo 'ACC +@0x8 +\w+ +\[0\+:32\] +RO'      'ACC: 32 bits at 0x08, RO'
falta_campo 'STATUS +@0xc +\w+ +\[0\+:1\] +RO'    'STATUS.EN: bit 0 at 0x0C, RO'
falta_campo 'STATUS +@0xc +\w+ +\[1\+:1\] +RO'    'STATUS.OVF: bit 1 at 0x0C, RO'
echo "STAGE 1 OK: four registers, six fields, and the map says what the spec says"

# --- Stage 2: the accesses ----------------------------------------------------
# uvm_reg_hw_reset_seq and uvm_reg_bit_bash_seq come from uvm-core and know nothing
# about this DUT: they read your model and generate the stimulus and the checking. They are the tests
# you did not write.
run_sim +UVM_TESTNAME=builtin_test +UVM_VERBOSITY=UVM_LOW || falta "builtin_test closed with
    UVM_ERROR. The DUT is healthy: the one getting it wrong is your model. If the error
    talks about a bit of CTRL, the CLR access is the suspect -- 'I wrote a 1 and
    read a 0' is what the spec says, not a bug."
echo "STAGE 2 OK: hw_reset and bit_bash green -- two tests you did not write"

# --- Stage 3: what the model cannot predict -----------------------------------
run_sim +UVM_TESTNAME=ral_test || falta "ral_test closed with UVM_ERROR.
    If the message is a STATUS mismatch, the model is not lying because of a wrong
    address: STATUS.EN is a copy of CTRL.EN and got there through a
    transfer to ANOTHER address. A register model cannot predict that,
    and saying so is part of modelling it. See the last <<< HERE >>> of the file."
echo "STAGE 3 OK: the model knows what it can predict and what it cannot"

echo
echo "EXERCISE OK: the register map of spec.md, as a UVM model."
echo "              You wrote 40 lines and got two tests for free."
