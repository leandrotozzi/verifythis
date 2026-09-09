#!/bin/bash
# Day 6 exercise. It fails until you solve it.
#
#   bash run.sh              with your files
#   SOLUCION=1 bash run.sh   with the ones in solucion/, to compare
#
# The TB is the whole one from the Agents section; from here come the agent and the env, which are
# the two files to touch.
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
INC=${SOLUCION:+ +incdir+solucion}
vlt_uvm top -Wno-fatal $INC -f dut.f -f tb.f

# +UVM_CONFIG_DB_TRACE makes UVM print every get() with the FULL PATH of the
# component that asked for it. Since the driver and the monitors ask for their
# config in build_phase, those lines are a census of the tree -- written by the
# library, not by the student.
run_sim +UVM_TESTNAME=dual_test +UVM_VERBOSITY=UVM_HIGH +UVM_CONFIG_DB_TRACE

falta() { echo "not yet: $1" >&2; exit 1; }
# The trailing space is what separates the path from the " = " UVM prints:
# without it, "modulo_agent_h" would also match "modulo_agent_h.driver_h".
existe() { grep -q "accessor=uvm_test_top\.env_h\.$1 " "$VLT_LOG"; }

if ! existe modulo_agent_h; then
  falta "there is no modulo_agent_h anywhere in the tree"
fi
if existe modulo_agent_h.driver_h; then
  falta "modulo_agent_h built a driver: is_active is doing nothing"
fi
if ! existe clase_agent_h.driver_h; then
  falta "clase_agent_h was left without a driver, and that one has to stay active"
fi

# Cross-checked grading: the passive agent has to be really WATCHING. Both
# counts come from the command_monitor and the scoreboard of the Agents section.
vistos=$(grep -c 'modulo_agent_h\.command_monitor_h.*MONITOR:' "$VLT_LOG" || true)
clase=$(grep -c 'clase_agent_h\.command_monitor_h.*MONITOR:' "$VLT_LOG" || true)
chequeados=$(grep -c 'modulo_scoreboard_h.*PASS' "$VLT_LOG" || true)

if [ "$vistos" -eq 0 ]; then
  falta "the passive agent did not see a single command: look at the scope of the set()"
fi
# The module sends 200 operations and the sequence more than a thousand. If both counts
# come out similar, the two agents are watching the SAME interface: the scope of the
# set() is wrong. Neither of those two numbers is yours to pick.
if [ "$vistos" -ge "$clase" ]; then
  falta "both agents are watching the same interface ($vistos against $clase): check the scope of the set()"
fi
if [ "$chequeados" -eq 0 ]; then
  falta "the module scoreboard checked nothing: you still have to connect the analysis ports"
fi

echo "EXERCISE OK: the passive agent saw $vistos commands and its scoreboard checked $chequeados"
