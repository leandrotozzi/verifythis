#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt top ejemplo2.sv
run_sim

# El contador estatico: dos pepes creados, un solo contador. Si dejara de ser
# compartido diria 1, y el ejemplo pasaria igual de verde.
expect_in_log 1 'NUMBER OF PEPES = 2'
