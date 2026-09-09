#!/bin/bash
# Day 1 exercise -- the waves. It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the one in solucion/, to compare
#
# It is the only exercise in the course that is NOT solved by reading the log.
# The log gives you one line; the rest is in ondas.vcd.
#
# It goes in stages, like the capstone:
#   STAGE 1  you read the waves: the two response times in respuesta.txt
#   STAGE 2  you fixed the BFM: the run finishes without a single $error
#
# The TB is the conventional testbench one (u2/interfaces-bfm): from here come the
# BFM -- the one with the bug -- and the top, which brings the wave dump.
set -e
# --trace always: the waves are the exercise, not an opt-in. It has to be set
# BEFORE common.sh is sourced: that is where VLT_FLAGS gets assembled from it.
export VLT_TRACE=1
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
SRC=${SOLUCION:+solucion/}

falta() { echo "not yet: $1" >&2; exit 1; }

# --timescale: the two times the README asks for are read in picoseconds, and
# no source declares a timeunit -- without this they would depend on the
# simulator's default.
vlt top -Wno-fatal --timescale 1ps/1ps -f pkg.f "${SRC}vtalu_bfm.sv" -f tb.f top.sv -f dut.f

echo "=== running, and dumping ondas.vcd ==="
# The run ABORTS on the first $error while the bug is there: that is expected.
run_sim || true
[ -f ondas.vcd ] || falta "ondas.vcd was not generated. Check that top.sv has the \`ifdef VLT_TRACE block."

# The truth comes out of the .vcd itself, not out of a number written by hand
# here: that way the exercise survives a change of DUT or stimulus. The two times
# asked for are the same with the broken BFM and with the healthy one -- they
# happen BEFORE the bug desynchronizes anything -- so fixing it changes nothing.
#   done       top.DUT.done        start_mult  top.DUT.start_mult
# The one-letter ids come from the $var section of the .vcd header.
ids() { awk -v s="$1" '/\$scope module DUT/ { d = 1 }
                       d && $0 ~ ("\\$var .* " s " \\$end") { print $(NF-2); exit }' ondas.vcd; }
ID_DONE=$(ids done); ID_MUL=$(ids start_mult)
[ -n "$ID_DONE" ] && [ -n "$ID_MUL" ] || falta "could not find done/start_mult in ondas.vcd"

read -r T_PRIMERO T_MUL <<EOF
$(awk -v d="$ID_DONE" -v m="$ID_MUL" '
    /^#/ { t = substr($0,2)+0; next }
    $0 == "1" m { if (!sm) sm = t }
    $0 == "1" d { if (!p) p = t; if (sm && !dm) dm = t }
    END { print p, dm }' ondas.vcd)
EOF

echo ""
echo "=== STAGE 1: read the waves ==="
[ -f "${SRC}respuesta.txt" ] || falta "respuesta.txt is missing. Open the waves
    (gtkwave ondas.vcd, or surfer) and write down the two times the README asks for,
    one per line, in picoseconds and without the unit."

# Two numbers, one per line; comments and blank lines are ignored.
R=(); while read -r n; do R+=("$n"); done < <(grep -oE "^[0-9]+" "${SRC}respuesta.txt")
[ "${#R[@]}" -ge 2 ] || falta "respuesta.txt has ${#R[@]} number(s) and 2 are needed:
    the first rising edge of done, and the one of the FIRST multiplication."

[ "${R[0]}" = "$T_PRIMERO" ] ||
  falta "the first rising edge of done is not ${R[0]} ps.
    Put the cursor on the FIRST rising edge of done and read the time."
[ "${R[1]}" = "$T_MUL" ] ||
  falta "the done of the first multiplication is not ${R[1]} ps.
    Look for the first stretch with op = mul_op (or start_mult at 1) and read the
    time of the rising edge of done that closes it."
echo "STAGE 1 OK: you read the waves -- first done at $T_PRIMERO ps, the one of the first multiplication at $T_MUL ps"

echo ""
echo "=== STAGE 2: fix the BFM ==="
# The run first, the grep after: a wait(done) fails the run (done is a level
# still up from the previous op, so start drops before the DUT sees the new
# one), and a repeat(5) passes the run while still counting cycles. Each gets
# the message that is true for it.
run_sim || falta "the run still reports errors: look at the lines above"
grep -q 'while *( *done' "${SRC}vtalu_bfm.sv" ||
  falta "send_op still counts cycles. The DUT says when it finished: wait for the
    handshake (done), not a number of edges. It is one line."
echo "STAGE 2 OK: the BFM waits for the handshake and no operation fails"
echo ""
echo "EXERCISE OK"
