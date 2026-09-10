#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
vlt top -f sv.f
run_sim

# The point of the section: with 'virtual', calling servir() through the base
# class handle runs the derived one. So every drink gets served TWICE, once
# through its own handle and once through trago's. Without virtual dispatch it
# would come out only once.
expect_in_log 2 'Fernet: 70/30, and the coke last'
expect_in_log 2 'Mojito: mint, lime and crushed ice'
