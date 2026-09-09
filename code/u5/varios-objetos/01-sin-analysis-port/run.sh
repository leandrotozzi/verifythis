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

# Los dos dados salen de un randomize() con constraints, y randomize() devuelve
# 0 --sin decir nada-- cuando falta el solver z3. Ahi los dados quedan en 0, la
# tirada es siempre 0, y el ejemplo termina "verde" mostrando 0 % de cobertura y
# un promedio de 0.0. Es la unica forma que tiene este ejemplo de fallar, asi
# que la miramos.
if grep -qE 'COVERAGE: +0%|DICE AVERAGE: +0\.0' "$VLT_LOG"; then
   echo "FAIL: los dados dieron siempre 0 — randomize() no resolvio." >&2
   echo "      Casi siempre es que falta z3: instalalo y volve a correr." >&2
   exit 1
fi
cov_report
