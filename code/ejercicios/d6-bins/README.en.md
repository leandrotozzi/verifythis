<!-- es-sha: 2c74f490caf5 -->
# Day 6 ·sequences — closing a bin

The course says twice that the daily work of the verifier is to **run, look at
which bin is missing, write the directed case, run again**. This is that
exercise.

The testbench is the whole one from sequences, with a test already written
(`cierre_test.svh`) that sends a reset, 60 random operations, and then your
sequence. **Of all that, the only thing you write is the last one.**

```sh
bash run.sh
```

`run.sh` runs the test twice: the first time with `+SIN_CIERRE`, which skips your
sequence, and that way you see the starting coverage. The second one already includes you.

## What is asked

**`cierre_sequence.svh`** — a sequence of a single item, that sends
`A = 8'hFF`, `B = 8'hFF` and `op = mul_op`. It is the bin *"both legs at `FF`,
multiplying"* of the coverage plan of the conventional testbench, and 60 random operations
do not fill it.

Concretely it is **row 3** of the verification plan
([`docs/plan-de-verificacion.md`](../../../docs/plan-de-verificacion.md), in Spanish): the
overflow of the multiplier, the only row of the twelve whose stimulus column
says **directed case**. And nobody decided that by hand: `FF` × `FF` is one
combination out of 65,536, so the random does not visit it. The plan is what makes
it obvious which test has to be written — this one.

But do not ask for it by assigning the fields: **ask for it with `randomize() with {}`**. The
directed case gets asked for at the point of use, and that is the tool of the transactions. `run.sh` checks that your file calls `randomize()`.

Done when `bash run.sh` prints `EXERCISE OK` — that is, when the coverage
of the second run is **greater** than that of the first.

## How to run it

```sh
bash run.sh              # with your file
SOLUCION=1 bash run.sh   # with the one in solucion/, to compare
```

The seed is fixed inside the `run.sh` on purpose. Without fixing it, some
runs would fill the bin on their own with the 60 random ones and there would be nothing to close —
which is exactly the topic of the other exercise, [`d6-semillas`](../d6-semillas/).

## How long it takes

This exercise compiles the whole of UVM. Measured with Verilator 5.052:

| | 12 cores | 2 cores (free Codespaces) |
|---|---|---|
| the first time | ~1 min 30 | ~4 min |
| the following ones, with `ccache` | ~15 s | ~15 s |

A `ccache` hit is copying a file, so the second compilation takes the
same on any machine. Install it before starting —the `run.sh` detects it
on its own— or use Codespaces, which already brings it.

**`z3`** is also needed: Verilator resolves `randomize()` with constraints by
calling an external SMT solver, and without it `randomize()` returns 0 without saying
anything.

## Hints, in order of usefulness

- **If `randomize()` returns 0 to you, it is not your `with`.** `command_transaction`
  has a `dist` on `A` and on `B`, and Verilator resolves the `dist` by
  choosing a value **before** looking at the rest of the constraints: if the one it
  drew does not satisfy your `with`, it returns 0 instead of looking for another. With
  `A dist {00 :/ 1, [01:FE] :/ 2, FF :/ 1}`, `with {A == 8'hFF}` resolves one out of
  every four times. The way around it is one line and it is in the Constrained random section.
- That way around it is, besides, the right thing here even if the simulator were perfect: a
  **directed** case does not want a distribution of probabilities, it wants a value.
- `randomize()` is checked with an `if`, never with `assert()`. A simulator with
  asserts disabled does not execute the argument, and your transaction comes out with
  whatever it had.
- The `result` is written by the driver inside the item, right before
  `item_done()`: it is only valid **after** `finish_item()` has come back.

## What it practises

`randomize() with {}` and `constraint_mode()`, `body()` and
`start_item`/`finish_item`, and reading a coverage report to decide what to
write. Which is what makes *coverage closure* a verb and not a
noun: you do not write one test per bin, you look at the report and you write
three lines.
