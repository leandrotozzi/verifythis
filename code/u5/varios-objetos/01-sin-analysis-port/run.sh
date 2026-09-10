#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
#
# --coverage-user: measures the covergroups and leaves out line/toggle/branch,
# which are not the topic. The number comes out at the end, with cov_report.
#
# -Wno-fatal: the examples have sloppy widths on purpose (WIDTHEXPAND/WIDTHTRUNC)
# and by default any warning stops the build. They still get printed.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal dice_pkg.sv top.sv
run_sim

# The two dice come out of a randomize() with constraints, and randomize()
# returns 0 --without saying anything-- when the z3 solver is missing. The dice
# then stay at 0, every roll is 0, and the example ends up "green" showing 0 %
# coverage and an average of 0.0. It is the only way this example has of failing,
# so we look at it.
if grep -qE 'COVERAGE: +0%|DICE AVERAGE: +0\.0' "$VLT_LOG"; then
   echo "FAIL: the dice always came out 0 -- randomize() did not solve." >&2
   echo "      It is almost always a missing z3: install it and run again." >&2
   exit 1
fi
cov_report
