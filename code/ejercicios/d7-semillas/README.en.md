<!-- es-sha: 9e2c7d742e1f -->
# Day 7 · warm-up — the same sequence, another seed

The table *"this is how coverage gets closed"* of the Constrained random section ends with a row that
the course never does: **repeat with another seed**. This exercise does it, and it
opens day 7: it is ten minutes, no SystemVerilog gets written, and it leaves in
place the `make regresion` that the afternoon's capstone is going to ask for.

It is the only one of the course where you do not write SystemVerilog. The testbench and the test are
already there: reset and **25** random operations. What you write is the regression.

```sh
bash run.sh
```

## What is asked

**`regresion.sh`** — that it run the same test with seeds **1 to 5**, leave the
coverage of each one in `$VLT_OBJ/seed.<N>.dat`, and merge the five into
`$VLT_OBJ/regresion.dat`.

The file has at the top everything that is available (`run_sim`, `SEED`,
`$VLT_OBJ`) and the merge command. It is six lines of shell.

Done when `bash run.sh` prints `EXERCISE OK` — that is, when the merge of the
five covers **more** than the best of the five on its own.

## How to run it

```sh
bash run.sh              # with your regresion.sh
SOLUCION=1 bash run.sh   # with the one in solucion/, to compare
```

## Why 25 operations and not 1000

Because with 1000 **this does not work**, and that is half the lesson.

It is measured and it is on the slide *"another seed, and again"*: `code/u2/convencional` and
`code/u7/sequences` give 66 out of 76 bins with the default seed, with seed 7 and with seed 8, and
the merge of the three also gives 66. With 1000 operations the random has already got as far
as it can get, and the 10 bins that are missing are not missing by luck — they are the
slots of `rst_op` and `no_op` in the cross, which `ignore_bins` should take out and
Verilator does not. No seed is ever going to touch them.

With 25 the stimulus has not saturated yet, and there it does: each seed covers a
different piece and the merge adds up. Which is exactly the situation of a real chip,
where the space is so large that it never saturates.

**The rule that remains:** another seed is good for **accumulating** while the stimulus
has not saturated, and for **reproducing** an intermittent failure. It is no good for filling a
bin the stimulus cannot reach — that is what the directed case of the
exercise [`d5c`](../d5c/) is for.

## How long it takes

It compiles the whole of UVM the first time: ~1 min 30 on a 12-core laptop, ~4 min on
a free Codespaces. The following ones, ~15 s on either of the two with `ccache`
installed. The five simulations together are one second: they are 25 operations each
one.

**`z3`** is also needed, the solver of `randomize()`.

## What it practises

That a **regression** is one test run many times with different seeds, not
many different tests. That coverage **accumulates** and has to be merged —
`verilator_coverage --write` is here what the `ucdb` merge is in Questa. And that
`SEED=N` is what makes a failure that shows up once every ten runs reproducible:
without that it cannot be debugged, because it cannot be repeated.
