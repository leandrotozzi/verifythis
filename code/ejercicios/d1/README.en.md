<!-- es-sha: bcd5c127e93c -->
# Day 1 — a new operation, end to end

Two files: a copy of the DUT single-cycle block and a copy of the conventional
testbench, put here so that you can break them in peace. The VTALU top and the
multiplier come from the course, untouched.

The VTALU has **one free opcode**: `3'b110`. It is reserved on purpose, and today
it does nothing. You are going to teach it to shift, and to teach the testbench
that it has to verify it too.

## What is asked

1. **`vtalu_1c.sv`** — implement the right shift on `3'b110`.
   Careful with the width: the hardware shifts by `B[2:0]`, not by the whole `B`. With
   `B = 8'h20` it shifts **zero** places, not thirty-two.
2. **`vtalu_tb.sv`** — add `shr_op = 3'b110` to the `operation_t`, make
   `get_op()` generate it and the scoreboard predict it **the same way the hardware does**.
3. **`vtalu_tb.sv`, the covergroup** — `bins single_cycle[]` covers the range
   `[add_op : xor_op]`, which reaches up to `3'b100`. `shr_op` falls **outside
   every bin**: it runs, it passes the scoreboard, and it does not show up in the report.
   Put it in.

Done when `bash run.sh` finishes with `EXERCISE OK`.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

If a result does not match the model, the scoreboard's `$error` aborts the
simulation: Verilator treats it as an assertion.

## What it practises

The VTALU spec, the conventional testbench and functional coverage. Plus two
lessons that are on no slide:

- **A new operation gets touched in three places** —the DUT, the stimulus with its
  check, and the measure— and if you forget one, the one that finds out is the TB.
- **An opcode nobody measures is an opcode nobody verified.** Step 3 is the
  most skipped one, and it is the only one of the three that fails **silently**: without
  touching the bins, the simulation passes green and the coverage does not move.

With the solution, the coverage goes from **86.8 % to 100 %**: the shift adds its
own bin and along the way closes the ones that were still open.
