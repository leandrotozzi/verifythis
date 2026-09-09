<!-- es-sha: 2e8f802ad2b4 -->
# Day 7 — the legacy module violates the protocol and nobody knew

The testbench is the whole one from the assertions, with its two VTALU: one is driven by the
driver of the agent, the other by `vtalu_tester_module` — the "boss's tester",
an ordinary module, without one line of UVM, that has been in production for years.

That module **violates the protocol**: for the multiplication it does not call
`bfm.send_op()` but moves the wires by hand, and it takes advantage of the cycles the
DUT spends answering to go about getting the operand of the next one ready.

The scoreboard **does not see it**, and it is not that it is broken: the multiplier latches `A` and
`B` on the first edge, so the result comes out right all the same. A thousand comparisons,
zero differences.

## What is asked

**`vtalu_bfm.sv`** — write the property that does see it. The rule has been in prose
since slide 1 of day 1: *while `start` is up, the operands and the
operation are not touched.*

The two `done` properties are already done and serve as a mould. The failure action
has to be a `` `uvm_error `` with the id `"SVA"`: if you let the
assertion end in `$stop`, the simulation gets cut off, the *Report Summary* does not get
printed and the checker sees nothing.

Done when `bash run.sh` prints `EXERCISE OK`.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

The checker asks for **three** things, and the middle one is the one that makes the exercise:

1. that the property fire on `modulo_bfm`, which is the one that violates the protocol;
2. that it **not** fire even once on `clase_bfm`, which is the one driven by the
   driver and respects it;
3. that the scoreboard stay green, so it is clear who caught what.

## How long it takes

This exercise compiles the whole of UVM. Measured with Verilator 5.052:

| | 12 cores | 2 cores (free Codespaces) |
|---|---|---|
| the first time | ~1 min 30 | ~4 min |
| the following ones, with `ccache` | ~15 s | ~15 s |

## Hints, in order of usefulness

- If your property never fires, add a `cover property` to it with the same
  antecedent and look at the `user:` of the coverage report. A cover at 0 means
  that the antecedent does not occur — not that the DUT is healthy.
- If it fires **on both** interfaces, the problem is the **edge**. Look at
  which edge `bfm.send_op()` writes the operands on, and remember that SVA
  samples in the *preponed* region: a signal written **on** an edge is not seen
  on that edge, it is seen on the next one. The two `done` properties that are already there
  use `@(posedge clk)`; this one cannot.
- `$stable(x)` compares against the previous sample, which is exactly what
  is needed. And it is three signals, not one: `A`, `B` and `op_set`.
- The implication takes `|=>` and not `|->`: the consequent is *"on the next
  edge"*, because an operand that changes on the same edge `start`
  goes up is not a violation, it is the start of the transaction.
- If the `run.sh` compiles and nothing at all fires, check that the `else` of your
  assertion has the `` `uvm_error `` with the id `"SVA"` — the checker looks for it
  by that id.

## What it practises

The property of the assertions (`$stable`, `|=>`, `disable iff`), the choice of the
**sampling edge** —which is the lesson of the section— and the underlying idea: an
assertion lives in the interface and therefore checks **everybody who uses it**,
including code nobody wrote with UVM in mind.
