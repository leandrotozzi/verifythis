#!/bin/bash
# Los cuatro experimentos de Constrained Random. Sin UVM: compilan en segundos.
# Ver docs/verilator.md.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../../verilator/common.sh"

for f in 01_dist 02_with 03_solve 04_falla; do
  echo "--- $f"
  vlt "top_${f#*_}" -Wno-fatal -Wno-WIDTHTRUNC "$f.sv"
  run_sim
done
