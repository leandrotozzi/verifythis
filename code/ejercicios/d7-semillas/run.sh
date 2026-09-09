#!/bin/bash
# Day 7 exercise (warm-up) -- another seed. It fails until you solve it.
#
#   bash run.sh              with your regresion.sh
#   SOLUCION=1 bash run.sh   with the one in solucion/, to compare
#
# The test is reset + 25 random operations. 25 and not 1000 on purpose: with 1000
# the random already goes as far as it can and every seed gives the same number
# -- measure it, it is on the "another seed, and again" slide of the Constrained random section.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f

falta() { echo "not yet: $1" >&2; exit 1; }
bins() { verilator_coverage "$1" 2>/dev/null | sed -nE 's/.*covergroup *: *[0-9.]+% *\( *([0-9]+)\/.*/\1/p'; }

rm -f "$VLT_OBJ"/seed.*.dat "$VLT_OBJ/regresion.dat"
. "${SOLUCION:+solucion/}regresion.sh"

dats=$(ls "$VLT_OBJ"/seed.*.dat 2>/dev/null | sort)
n=$(printf '%s\n' $dats | grep -c . || true)
[ "$n" -ge 5 ] ||
  falta "I found $n seed.<N>.dat file(s) and 5 are needed, one per seed"

echo "=== coverage of each seed ==="
mejor=0
for d in $dats; do
  b=$(bins "$d")
  printf '    %-14s %s bins\n' "$(basename "$d")" "$b"
  [ "$b" -gt "$mejor" ] && mejor=$b
done

[ -f "$VLT_OBJ/regresion.dat" ] ||
  falta "the merge is missing: verilator_coverage --write \$VLT_OBJ/regresion.dat \$VLT_OBJ/seed.*.dat"
merge=$(bins "$VLT_OBJ/regresion.dat")
echo "=== the five, merged ==="
printf '    regresion.dat  %s bins\n' "$merge"

[ "$merge" -gt "$mejor" ] ||
  falta "the merge gives $merge bins and the best seed alone already gave $mejor.
    If they are equal, the most likely thing is that you merged a single .dat, or that
    the five are copies of the same run: check that run_sim gets a
    different SEED on each pass -- it prints it on start."

echo "EXERCISE OK: the best seed alone reaches $mejor bins; the five merged, $merge"
