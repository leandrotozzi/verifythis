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
# The two times the checker demands come out of RUNNING the reference BFM, and
# solucion/vtalu_bfm.sv plus the top that dumps the waves are sealed. See
# intocables.sha.
intocables
SRC=${SOLUCION:+solucion/}

falta() { echo "not yet: $1" >&2; exit 1; }

# --timescale: the two times the README asks for are read in picoseconds, and
# no source declares a timeunit -- without this they would depend on the
# simulator's default.
build() { vlt top -Wno-fatal --timescale 1ps/1ps -f pkg.f "$1" -f tb.f top.sv -f dut.f; }
# The run ABORTS on the first $error while the bug is there: that is expected.
corre() {
  run_sim || true
  [ -f ondas.vcd ] || falta "ondas.vcd was not generated. Check that top.sv has the \`ifdef VLT_TRACE block."
}

# The truth comes out of the .vcd itself, not out of a number written by hand
# here: that way the exercise survives a change of DUT or stimulus.
#   done       top.DUT.done        start_mult  top.DUT.start_mult
# The one-letter ids come from the $var section of the .vcd header.
ids() { awk -v s="$1" '/\$scope module DUT/ { d = 1 }
                       d && $0 ~ ("\\$var .* " s " \\$end") { print $(NF-2); exit }' ondas.vcd; }
tiempos() {
  local d m
  d=$(ids done); m=$(ids start_mult)
  [ -n "$d" ] && [ -n "$m" ] || falta "could not find done/start_mult in ondas.vcd"
  awk -v d="$d" -v m="$m" '
    /^#/ { t = substr($0,2)+0; next }
    $0 == "1" m { if (!sm) sm = t }
    $0 == "1" d { if (!p) p = t; if (sm && !dm) dm = t }
    END { print p, dm }' ondas.vcd
}

# The reference: the same testbench with the BFM of solucion/, built and run
# here, every run. It is what STAGE 2 compares against, and it is measured and
# not written down: the day the DUT or the stimulus changes, the number changes
# with them.
#
# It used to be the other way round --the times of the BFM as shipped, measured
# ONCE and cached in obj_dir-- and that lied in both directions: with the BFM
# already fixed the waves said 650 ps and the checker went on demanding 830, and
# after a make clean it demanded 650 from an answer that had been read off the
# shipped waves. Nothing is cached now: every number the checker prints was
# measured in this run.
build solucion/vtalu_bfm.sv
corre > /dev/null
read -r I_PRIMERO I_MUL <<< "$(tiempos)"

if [ -n "$SRC" ]; then
  T_PRIMERO=$I_PRIMERO; T_MUL=$I_MUL
else
  # Two builds within the same second come out stale on macOS (its make 3.81
  # compares whole seconds, and the regenerated .cpp is not newer than the .o),
  # so start clean.
  rm -rf obj_dir/top
  build vtalu_bfm.sv
  echo "=== running, and dumping ondas.vcd ==="
  corre
  read -r T_PRIMERO T_MUL <<< "$(tiempos)"
fi

echo ""
echo "=== STAGE 1: read the waves ==="
[ -f "${SRC}respuesta.txt" ] || falta "respuesta.txt is missing. Open the waves
    (gtkwave ondas.vcd, or surfer) and write down the two times the README asks for,
    one per line, in picoseconds and without the unit."

# Two numbers, one per line; comments and blank lines are ignored.
R=(); while read -r n; do R+=("$n"); done < <(grep -oE "^[0-9]+" "${SRC}respuesta.txt")
[ "${#R[@]}" -ge 2 ] || falta "respuesta.txt has ${#R[@]} number(s) and 2 are needed:
    the first rising edge of done, and the one of the FIRST multiplication."

# Against the waves THIS run just left, which are the ones you have open.
[ "${R[0]}" = "$T_PRIMERO" ] ||
  falta "in ondas.vcd the first rising edge of done is at $T_PRIMERO ps, and
    respuesta.txt says ${R[0]}. Put the cursor on the FIRST rising edge of done and
    read the time."
[ "${R[1]}" = "$T_MUL" ] ||
  falta "in ondas.vcd the done of the first multiplication is at $T_MUL ps, and
    respuesta.txt says ${R[1]}. Look for the first stretch with op = mul_op (or
    start_mult at 1) and read the time of the rising edge of done that closes it.
    If you already fixed send_op, that number MOVED, and the move is the lesson:
    every one-cycle operation now takes one edge less, so the first multiplication
    starts --and closes-- earlier. Open the waves again and write down what they say."
echo "STAGE 1 OK: you read the waves -- first done at $T_PRIMERO ps, the one of the first multiplication at $T_MUL ps"

echo ""
echo "=== STAGE 2: fix the BFM ==="
# Two ways of getting it wrong and two messages, and neither of them reads the
# shape of your code: a wait(done) fails the run (done is a level still up from
# the previous op, so start drops before the DUT sees the new one), and a
# repeat(5) passes the run while still counting cycles -- it just counts too
# many. What gives the second one away is the clock, not the grep: waiting more
# edges than the DUT needs pushes every response later than the reference.
run_sim || falta "the run still reports errors: look at the lines above"
[ "$T_MUL" = "$I_MUL" ] ||
  falta "no operation fails any more, but send_op is still going by the clock and
    not by the handshake: in your waves the first multiplication closes at $T_MUL ps
    and with the handshake it closes at $I_MUL. Waiting MORE edges than the DUT needs
    also keeps the scoreboard quiet, and it is the same bug: the DUT says when it
    finished."
echo "STAGE 2 OK: the BFM waits for the handshake and no operation fails"
echo ""
echo "EXERCISE OK"
