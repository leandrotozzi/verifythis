<!-- es-sha: 724e0abd11a4 -->
**English** · [Castellano](README.es.md)

# Day 4 — the `#500` is a patch

The testbench is the one from *put and get*, with **one line changed**: the
`env`'s FIFO comes unbounded (`new("command_f", this, 0)`).

With the usual size of 1, `put()` blocked the tester until the driver took the
previous command. That back-pressure was what kept the tester in step with the
bus — without anybody having designed it that way. With no ceiling nobody
blocks: the tester empties its thousand commands at `t = 0`, waits the usual
`#500`, drops the objection, and the simulation **ends in green with the bus half
empty**.

## What is asked for

**`driver.svh`** — that the driver holds an objection **while it has a command in
flight**. The pair is `phase.raise_objection(this)` /
`phase.drop_objection(this)`, the same one as the day 3 test, and `phase` is the
argument of `run_phase`.

Done when `bash run.sh` prints `EXERCISE OK`.

`env.svh` does not get touched: the unbounded FIFO **is the DUT of this
exercise**. Putting the ceiling back hides the problem instead of fixing it, and
the checker's `shasum -c intocables.sha` catches it before compiling.

## Why the `#500` was never the solution

The *put and get* section says it in passing and here it gets collected: `#500`
is a magic number somebody measured once. With the size-1 FIFO it was enough by
chance —the tester was already going at the speed of the bus, so it did not have
far to go—; with the unbounded FIFO it is not remotely enough. Both times the
problem is the same: **the tester does not know when the bus is done**. It knows
when it is done *putting*.

The one that does know is the driver, because it is the one driving. That is why
the objection goes there, and that is why this is the pattern any real UVM driver
uses.

And the detail of where the pair goes, which is what decides whether the exercise
works: **after** the `get()`, not around it. Around it, the driver holds an
objection waiting for work that is never coming, and the test never ends.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the one in solucion/, to compare
```

## How long it takes

It compiles the whole of UVM, like the rest of the day 4 exercises:

| | 12 cores | 2 cores (free Codespaces) |
|---|---|---|
| the first time | ~1 min 30 | ~4 min |
| the following ones, with `ccache` | ~15 s | ~15 s |

## What it practises

Real objections —who raises them and why that one and not another—, blocking
`put()` and back-pressure, and the underlying lesson: **a `#N` in a testbench is
an unanswered question**. And along the way, UVM's most expensive failure mode: a
simulation that ends early **does not fail**. It says PASS.
