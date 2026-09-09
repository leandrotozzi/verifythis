#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
# --timescale: without this Verilator takes its 1ps default and the #17 / #7 of the
# example become picoseconds, so the output and the diagram on the
# slide ("every 17 ns") said different things. It goes as a flag and not as a
# `timescale in the source because declaring it in one module forces declaring it
# in ALL of them -- and uvm_pkg does not declare it: %Warning-TIMESCALEMOD, fatal. The flag,
# on the other hand, is the default for whoever says nothing, uvm_pkg included.
vlt_uvm top --timescale 1ns/1ns example_pkg.sv top.sv
run_sim
