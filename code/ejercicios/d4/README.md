<!-- es-sha: 7615e866ac47 -->
**English** · [Castellano](README.es.md)

# Day 4 — one more observer, without touching the ones already watching

The testbench is the one from the analysis ports: the `command_monitor` publishes
every command over a `uvm_analysis_port`, and on the other side the `coverage`
and the `scoreboard` are listening. We want to add one that counts.

## What is asked

1. **`op_counter.svh`** — a `uvm_subscriber #(command_s)` that counts the
   commands that reach it (and the `mul_op`s separately), and that in
   `report_phase` prints, with `UVM_NONE` verbosity and the id `OP_COUNTER`:

   ```
   commands=<n> multiplications=<m>
   ```

   The checker looks for that line as it is: `commands=` is what it greps for.

2. **`env.svh`** — instantiate it and connect it to the analysis port of the
   `command_monitor`, without touching the connections that are already there.

Done when `bash run.sh` prints `EXERCISE OK`.

The marking is done by cross-checking: your `commands=` has to come out the same
as the number of `[COMMAND MONITOR]` lines the monitor prints, which you did not
write. If you forget the `connect`, your counter says 0 and the monitor says 1000.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
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

## What it practises

Analysis ports and the observer pattern, `build_phase` and `connect_phase`. The
underlying point: **the one who publishes never finds out who is listening**, and
that is why adding an observer does not touch one line of the ones that were
already there.
