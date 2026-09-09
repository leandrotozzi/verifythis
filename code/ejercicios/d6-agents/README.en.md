<!-- es-sha: 6075a9fc81cd -->
# Day 6 — the agent that only watches

The testbench is the one from the agents, but trimmed: there is **a single agent**, the
one that drives `clase_bfm`. The second VTALU is driven by `vtalu_tester_module` and nobody
is watching it.

## What is asked

1. **`vtalu_agent.svh`** — today the `build_phase` builds the sequencer and the
   driver **always**, so `is_active` is good for nothing. Make them get
   built only when the agent is active. The `connect_phase` too.

2. **`env.svh`** — add the second agent:
   - its `vtalu_agent_config`, with `modulo_bfm` and `UVM_PASSIVE`
   - the `set()` in the `uvm_config_db`, **with the scope that belongs to it**
   - the agent, a `scoreboard` and a `coverage` of its own
   - the two connections, against the analysis ports **of the agent**

   The names matter: the checker looks for `modulo_agent_h` and
   `modulo_scoreboard_h`, the same way as the `clase_*` ones already there.

Done when `bash run.sh` prints `EXERCISE OK`.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

To see the tree of components with your own eyes and not with the checker's:

```sh
bash ../../u7/agents/run.sh +TOPOLOGY
```

## How long it takes

This exercise compiles the whole of UVM. Measured with Verilator 5.052:

| | 12 cores | 2 cores (free Codespaces) |
|---|---|---|
| the first time | ~1 min 30 | ~4 min |
| the following ones, with `ccache` | ~15 s | ~15 s |

A `ccache` hit is copying a file, so the second compilation takes the
same on any machine. Install it before starting —the `run.sh` detects it
on its own— or use Codespaces, which already brings it.

## Hints, in order of usefulness

- The scope of the `set()` is the **path** of the component that is going to read, not a
  free-form name. With `"*"` on both lines, the second overwrites the first and
  both agents start up the same.
- The asterisk at the end matters: `"modulo_agent_h*"` also reaches the driver
  and the monitors inside. Without it, the agent finds its config and its children
  do not.
- If the `connect_phase` blows up with a `null`, it is because the passive agent has no
  driver and you are asking it for the `seq_item_port` all the same.

## What it practises

`is_active` and the scope of the `uvm_config_db`, analysis ports, and the
underlying idea of the section: **the agent is the unit that gets instantiated once per
interface**. The second VTALU does not need a new testbench. It needs one
more line.
