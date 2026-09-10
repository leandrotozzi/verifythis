#!/bin/bash
# Day 5 exercise (constrained random). It fails until you solve it.
#
#   bash run.sh              with your file
#   SOLUCION=1 bash run.sh   with the one in solucion/, to compare
#   SEED=7 bash run.sh       with another seed: the numbers move a little
#
# No UVM and no DUT: it compiles and runs in seconds. It is the exercise for
# whoever is short on time.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
# The histogram and its $display live in histograma_top.sv, which is sealed:
# what the checker measures has to come out of a file the exercise does not
# edit. Rewriting the HISTOGRAM line is not a way of solving it. See intocables.sha.
intocables
SRC=${SOLUCION:+solucion/}
vlt top_histograma -Wno-fatal -Wno-WIDTHTRUNC "${SRC}histograma.sv" histograma_top.sv
run_sim

falta() { echo "not yet: $1" >&2; exit 1; }

# The sample size travels with the class, so the run says how many draws it did.
# It is not part of what is asked: with a handful of draws the three percentages
# land on 10/80/10 by luck and the measurement stops meaning anything.
n=$(sed -nE 's/^([0-9]+) randomizations$/\1/p' "$VLT_LOG" | tail -1)
[ "${n:-0}" -eq 4000 ] ||
  falta "the run did ${n:-0} randomizations and the exercise is measured over 4000.
    N is in histograma.sv, next to the class, and it is not what is asked."

linea=$(grep -o 'HISTOGRAM .*' "$VLT_LOG" | tail -1)
[ -n "$linea" ] || falta "the HISTOGRAM line did not come out: look at the log above"

leer() { echo "$linea" | sed -nE "s/.*$1=([0-9.]+).*/\1/p"; }
ceros=$(leer 00); medio=$(leer mid); unos=$(leer FF)

# Tolerance of +-2 points per bucket. bc is not in every image;
# awk is, and it is also the one common.sh already uses.
lejos() { awk -v v="$1" -v o="$2" 'BEGIN {exit !(v < o - 2 || v > o + 2)}'; }

if lejos "$ceros" 10 || lejos "$unos" 10; then
  falta "the edges give 00=$ceros% and FF=$unos%, and they have to give 10% each.
    The weights already are 10, 80 and 10: the problem is not the numbers, it is the
    OPERATOR. See the slide 'dist: := is not the same as :/' of the Transactions section."
fi
lejos "$medio" 80 &&
  falta "the middle gives $medio% and it has to give 80%"

echo "EXERCISE OK: 00=$ceros%  mid=$medio%  FF=$unos%  (target 10/80/10, +-2)"
