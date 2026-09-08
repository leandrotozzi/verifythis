#!/bin/bash
# Corre el ejemplo con Verilator. Ver docs/verilator.md.
#
# --coverage-user: mide los covergroups y deja afuera line/toggle/branch, que no
# son el tema. El numero sale al final, con cov_report.
#
# -Wno-fatal: los ejemplos tienen anchos flojos a proposito (WIDTHEXPAND/WIDTHTRUNC) y
# por defecto cualquier warning corta el build. Se siguen imprimiendo.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt top --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim
cov_report
