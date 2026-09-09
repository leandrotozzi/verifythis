<!-- es-sha: 9a5e501cdfd3 -->
# Day 6 ·sequences — the tester of day 3, now as a sequence

The testbench is the whole one from sequences: agent, sequencer, driver, monitors,
coverage and scoreboard. **None of that has to be touched.** The only thing missing is
the stimulus.

## What is asked

1. **`mult_sequence.svh`** — a `uvm_sequence #(command_transaction)` that:
   - first sends a `rst_op`;
   - then sends **20 multiplications** with `A` and `B` at random;
   - counts how many it sent and keeps the **largest result** it saw;
   - prints at the end of `body()`, with verbosity `UVM_NONE`:

     ```
     items=<n> max=<m>
     ```

2. **`mult_test.svh`** — a test that extends `base_test`, creates the sequence through
   the factory and starts it on `sequencer_h`, with the objection around it.

Done when `bash run.sh` prints `EXERCISE OK`.

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

## Hints, in order of usefulness

- **The first item has to be a `rst_op`.** The VTALU starts up with `reset_n`
  at 0 and never raises `done`; without a reset the driver stays waiting and your
  sequence hangs in the first `finish_item()`. Look at `reset_sequence.svh`.
- To get only `mul_op` out you have two ways, both of them from day 5:
  `randomize() with {op == mul_op;}` —`op` has no `dist`, so here the `with`
  works— or `command.op = mul_op; command.op.rand_mode(0);` before
  `randomize()`.
- `command.result` is written by **the driver**, inside the item, right before
  `item_done()`. Which means it is only valid **after** `finish_item()` has come
  back. If you read it before, it is going to give you 0 and the checker is going to tell
  you so.
- The sequence is a `uvm_object`: `` `uvm_object_utils ``, constructor with a single
  argument, and `body()` is a **task**.

## What it practises

`body()` and the life cycle of the sequence, `start_item()` / `finish_item()`,
late randomization and `rand_mode()` / `with {}`. And the underlying idea:
**the stimulus gets changed without touching a line of structure**. The two files you
write are the only two this exercise has.
