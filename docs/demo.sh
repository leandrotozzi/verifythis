#!/bin/bash
# Replay de la salida real de `make u4/tests` para grabar el GIF del README.
#
#   vhs docs/demo.tape      # desde la raiz del repo -> docs/demo.gif
#
# Se replaya en vez de correrse en vivo porque el build de UVM con Verilator
# tarda varios minutos y el GIF dura 20 segundos. El texto de abajo es la
# salida verbatim de `make u4/tests` en esta maquina (Verilator 5.052 + UVM
# 2020.3.1), con dos recortes cosmeticos y ninguna linea inventada:
#
#   - las rutas absolutas de UVM acortadas al basename (no mostrar $HOME),
#   - el `%Warning: System has stack size ...` de `ulimit -s`, que es ruido del
#     entorno y no del ejemplo.
#
# El Coverage Summary va entero, con las filas line/toggle/branch en 0/0: no es
# que no mida, es que run.sh compila con --coverage-user y deja fuera todo lo
# que no sean covergroups. Mostrarlo igual que en la terminal > que quede lindo.

set -u

E=$(printf '\033')
PROMPT="${E}[38;5;245m~/verifythis${E}[0m ${E}[38;5;114m\$${E}[0m "

# tipea el comando letra por letra, como si lo escribieran
cmd() {
  printf '%s' "$PROMPT"
  local i
  for ((i = 0; i < ${#1}; i++)); do printf '%s' "${1:i:1}"; sleep 0.04; done
  sleep 0.45
  printf '\n'
}

# imprime un bloque, una linea cada $1 segundos
out() {
  local d=$1
  while IFS= read -r l; do printf '%s\n' "$l"; sleep "$d"; done
}

sleep 0.8

cmd 'verilator --version'
out 0.1 <<'EOF'
Verilator 5.052 2026-09-05 rev v5.052

EOF
sleep 1.1

cmd 'make u4/tests'
out 0.1 <<'EOF'
==> code/u4/tests/run.sh
EOF
sleep 1.8   # el build real son varios minutos

out 0.13 <<'EOF'
UVM_INFO @ 0: reporter [RNTST] Running test random_test...
UVM_INFO uvm_report_server.svh(1009) @ 42371: [UVM/REPORT/SERVER]

--- UVM Report Summary ---

** Report counts by severity
UVM_INFO :    1
UVM_WARNING :    0
UVM_ERROR :    0
UVM_FATAL :    0
** Report counts by id
[RNTST]     1

- uvm_root.svh:633: Verilog $finish
- S i m u l a t i o n   R e p o r t: Verilator 5.052 2026-09-05
- Verilator: $finish at 42ns; walltime 0.066 s; speed 642.676 ns/s
EOF
sleep 0.7

out 0.13 <<'EOF'
UVM_INFO @ 0: reporter [RNTST] Running test add_test...
UVM_INFO uvm_report_server.svh(1009) @ 40540: [UVM/REPORT/SERVER]

--- UVM Report Summary ---

** Report counts by severity
UVM_INFO :    1
UVM_WARNING :    0
UVM_ERROR :    0
UVM_FATAL :    0
** Report counts by id
[RNTST]     1

- uvm_root.svh:633: Verilog $finish
- S i m u l a t i o n   R e p o r t: Verilator 5.052 2026-09-05
- Verilator: $finish at 41ns; walltime 0.031 s; speed 1.294 us/s
EOF
sleep 0.7

out 0.2 <<'EOF'
Coverage Summary:
  line       : 0.0% ( 0/ 0)
  toggle     : 0.0% ( 0/ 0)
  branch     : 0.0% ( 0/ 0)
  expr       : 0.0% ( 0/ 0)
  fsm_state  : 0.0% ( 0/ 0)
  fsm_arc    : 0.0% ( 0/ 0)
  covergroup : 86.8% (66/76)
EOF

printf '%s' "$PROMPT"
sleep 6      # el tape corta antes: el GIF cierra en este prompt

