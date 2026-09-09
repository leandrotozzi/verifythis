#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"
# This example ENDS in $fatal: calling servir() on a generic trago
# is the error the section wants to show. It exits with a code != 0 on purpose,
# so PASS means that message showing up, not the exit code being 0.
vlt top -f sv.f
expect_output "A generic trago cannot be served"
