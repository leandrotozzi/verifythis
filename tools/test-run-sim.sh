#!/bin/bash
# Que el chequeo de run_sim siga distinguiendo una corrida limpia de una con
# errores. Usa como fixtures dos transcripts que ya estan en el repo, asi que
# corre en un segundo y no necesita ni simulador ni UVM.
set -e
cd "$(dirname "$0")/.."
. code/verilator/common.sh

uvm_summary_ok code/u4/tests/output.txt              # resumen en 0: pasa
! uvm_summary_ok code/u4/reporting/scoreboard1.txt 2>/dev/null   # 2 UVM_ERROR: falla
uvm_summary_ok /dev/null                         # sin resumen (ejemplo sin UVM): pasa
echo "ok: uvm_summary_ok"
