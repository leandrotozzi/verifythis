#!/bin/bash
# Runs the example with Verilator. See docs/verilator.md.
#
# The third hook: the same testbench as the Agents section, with two callbacks
# hanging off the driver. The env, the agent, the driver and the sequences are NOT touched.
#
#   dual_test     the usual one, without a single callback registered
#   inject_test   the SAME test, with jitter_cb and flip_bit_cb put on top
#
#   bash run.sh +CALLBACK_TRACE   prints the driver's callback queue
set -e
. "$(dirname "${BASH_SOURCE[0]}")/../../verilator/common.sh"
vlt_uvm top --coverage-user -Wno-fatal -f dut.f -f tb.f

run_sim +UVM_TESTNAME=dual_test
limpio=$VLT_LOG

run_sim +UVM_TESTNAME=inject_test "$@"
inyectado=$VLT_LOG

# Both callbacks really ran. This does NOT check the `uvm_register_cb: without that
# macro the add() still hooks the callback up and it still runs, with a CBUNREG
# warning (uvm_callback.svh:745, and the add() carries on at :781-786). What it does
# check is the effect -- an example that "passes" without having injected anything
# proves nothing, whatever the reason the queue came out empty.
# The bracket and the "A:" belong to the `uvm_info line; without them, the count
# by severity of the Report Summary counts itself.
flips=$(grep -c "\[FLIP_BIT_CB\] A:" "$inyectado" || true)
[ "$flips" -gt 0 ] ||
  { echo "FAIL: no callback ran — check the driver's \`uvm_register_cb" >&2; exit 1; }

# The jitter shows up in simulation time: same stimulus, more cycles.
tiempo() { sed -nE 's/.*\$finish at ([0-9]+)ns.*/\1/p' "$1" | tail -1; }
t_limpio=$(tiempo "$limpio"); t_inyectado=$(tiempo "$inyectado")

echo
echo "=== the third hook ==="
printf '    dual_test    %s bits dados vuelta, $finish en %s ns\n' 0 "$t_limpio"
printf '    inject_test  %s bits dados vuelta, $finish en %s ns\n' "$flips" "$t_inyectado"
echo
echo "    And the scoreboard did NOT scream in either run: the monitor watches"
echo "    the WIRE, not what the driver thought it was going to send. That is the best"
echo "    news this example gives, not a hole in the checker. See the slide."

cov_report
