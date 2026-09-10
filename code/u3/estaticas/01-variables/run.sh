#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt top -f sv.f
run_sim

# The three fernets were pushed from THREE different objects and come out of a
# single list, the static one of the class. If it stopped being shared the tray
# would hold a single glass, and without this check the example would pass anyway.
expect_in_log 3 'the one at'
