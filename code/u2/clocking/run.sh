#!/bin/bash
# Clocking block: the edge and the delta, declared once.
#
# Runs the three tops back to back, because the section IS the comparison:
#   1. sin_clocking  three ways to sample the same data -> three numbers
#   2. con_clocking  the same data, read three times -> the same number
#   3. mezcla        what the clocking block costs: two names for the same
#                    wire, and they are not worth the same
#
# The second one ends in $fatal if the clocking block does not give 11: that is
# the net that warns if a Verilator release changes the sampling semantics.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"

echo "=== 1) no clocking block: the edge and the delta, by hand, in every task ==="
vlt top_sin -Wno-fatal -f sv_sin.f
run_sim

echo ""
echo "=== 2) with a clocking block: declared once, in the interface ==="
vlt top_con -Wno-fatal -f sv_con.f
run_sim

echo ""
echo "=== 3) the trap: mixing the raw wire with the clocking block one ==="
vlt top_mezcla -Wno-fatal -f sv_mezcla.f
run_sim
