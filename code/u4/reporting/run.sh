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

# El scoreboard de esta seccion suma de mas A PROPOSITO: es el ejemplo con el
# que se ensena reporting. Sin este opt-out, run_sim fallaria por los uvm_error
# que la seccion quiere mostrar.
export UVM_ERRORS_OK=1
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f
run_sim +UVM_TESTNAME=random_test
cov_report
