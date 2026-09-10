<!-- es-sha: 01a427d56d0f -->
**English** · [Castellano](README.es.md)

# Day 5 · constrained random — closing a bin

The course says twice that the daily work of the verifier is to **run, look at
which bin is missing, write the directed case, run again**. This is that
exercise.

The testbench is the whole one from the Transactions section, with the `tester`
already written: it sends a reset, 60 random operations, and then the directed
case. **Of all that, the only thing you write is the directed case.**

```sh
bash run.sh
```

`run.sh` runs the test twice: the first time with `+SIN_CIERRE`, which skips your
directed case, and that way you see the starting coverage. The second one already
includes you.

## What is asked

**`tester.svh`**, inside the `el_cierre` block — a transaction carrying
`A = 8'hFF`, `B = 8'hFF` and `op = mul_op`. It is the *"both legs at `FF`,
multiplying"* bin of the coverage plan of the conventional testbench, and 60
random operations do not fill it.

Concretely it is **row 3** of the verification plan
([`docs/en/verification-plan.md`](../../../docs/en/verification-plan.md)): the
multiplier's **maximum product**, the only one of the twelve rows whose stimulus
column says **directed case**. And nobody decided that by hand: `FF` × `FF` is one
combination out of 65,536, so random never visits it.
To be clear, just in case: `FF` × `FF` **does not overflow**. It gives `FE01`,
which fits exactly in the 16 bits of `result`, and the DUT leaves `ovf` at 0 on
every multiplication. It is the maximum of the input space — that is why the bin
is called `mul_max`. The plan is what makes it obvious which test has to be
written — this one.

But do not ask for it by assigning the fields, which is what the section's
`tester` does three lines above: **ask for it with `randomize() with {}`**. The
directed case is asked for at the point of use, and that is the tool of this
unit. `run.sh` checks that your block calls `randomize()`.

Done when `bash run.sh` prints `EXERCISE OK` — that is, when the coverage of the
second run is **higher** than that of the first.

## How it is run

```sh
bash run.sh              # with your file
SOLUCION=1 bash run.sh   # with the one in solucion/, to compare
```

The seed is pinned inside `run.sh` on purpose. Without pinning it, some runs
would fill the bin on their own with the 60 random ones and there would be
nothing to close — which is exactly the topic of the day 7 morning exercise,
[`d7-semillas`](../d7-semillas/).

## How long it takes

This exercise compiles the whole of UVM. Measured with Verilator 5.052:

| | 12 cores | 2 cores (free Codespaces) |
|---|---|---|
| the first time | ~1 min 30 | ~4 min |
| the next ones, with `ccache` | ~15 s | ~15 s |

A `ccache` hit is copying a file, so the second compilation takes the same on any
machine. Install it before starting —the `run.sh` detects it on its own— or use
Codespaces, which already brings it.

**`z3`** is needed too: Verilator solves `randomize()` with constraints by
calling an external SMT solver, and without it `randomize()` returns 0 without
saying anything.

## Hints, in order of usefulness

- **If `randomize()` returns 0 to you, it is not your `with`.**
  `command_transaction` has a `dist` on `A` and on `B`, and Verilator solves the
  `dist` by picking a value **before** looking at the rest of the constraints: if
  the one it drew does not satisfy your `with`, it returns 0 instead of looking
  for another. With `A dist {00 :/ 1, [01:FE] :/ 2, FF :/ 1}`,
  `with {A == 8'hFF}` solves one time out of four. The workaround is one line and
  it is in the Constrained random section.
- That workaround is also the right thing here even if the simulator were
  perfect: a **directed** case does not want a spread of probabilities, it wants
  a value.
- `randomize()` is checked with `if`, never with `assert()`. A simulator with
  asserts disabled does not execute the argument, and your transaction goes out
  with whatever it had.
- The `tester` **does not touch the DUT**: it puts the transaction in a FIFO and
  the driver handles it. That is why `result` is not in the object you sent.

## What it practises

`randomize() with {}` and `constraint_mode()`, and reading a coverage report to
decide what to write. Which is what makes *coverage closure* a verb and not a
noun: you do not write a test per bin, you look at the report and you write three
lines.
