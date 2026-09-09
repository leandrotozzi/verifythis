<!-- es-sha: 9c3bd2446c3c -->
# Exercises

**Fifteen**, spread across the days. Each one marks itself: `run.sh` fails until
you solve it.

The **Needs** column says what has to be installed besides Verilator: `UVM` means
"it compiles the whole library the first time", and `z3` is the `randomize()`
solver — without it, `randomize()` returns 0 silently.

| | Day | What | Comes from | Needs |
|---|:--:|---|---|---|
| [`d1`](d1/) | 1 | A new operation, end to end: RTL, TB and coverage | units 1 and 2 | — |
| [`d1b`](d1b/) | 1 | **The waves**: the log gives one line and the rest is in the `.vcd` | The VTALU spec · Interfaces and BFM | — |
| [`d2`](d2/) | 2 | A tester that only multiplies, without copying the whole class | unit 3 | — |
| [`d3`](d3/) | 3 | The same tester, now with a factory override and without touching the `env` | unit 4 | UVM |
| [`d4`](d4/) | 4 | One more subscriber hanging off the analysis port | unit 5 | UVM |
| [`d5`](d5/) | 5 | The scoreboard screams and the DUT is healthy: find the bug | units 5 and 6 | UVM |
| [`d5b`](d5b/) | 5 | Measure your `dist`: the weights are right and the histogram lies | Constrained random | z3 |
| [`d6-agents`](d6-agents/) | 6 | The agent that only watches: `is_active` and the scope of the `config_db` | Agents | UVM |
| [`d6-sequences`](d6-sequences/) | 6 | A sequence that only multiplies, without touching the structure | Sequences | UVM |
| [`d6-bins`](d6-bins/) | 6 | Closing a bin with `randomize() with {}` | Constrained random and Sequences | UVM · z3 |
| [`d6-semillas`](d6-semillas/) | 6 | Five seeds and a merge: what a regression is | Constrained random and Sequences | UVM · z3 |
| [`d7-sva`](d7-sva/) | 7 | The legacy module violates the protocol: write the property that sees it | Assertions | UVM |
| [`d7-final`](d7-final/) | 7 | **Capstone**: an APB slave, its spec, and the whole testbench from scratch | everything | UVM · z3 |
| [`d8-ral`](d8-ral/) | 8 | The register map of the spec, as a UVM model | RAL (unit 9) | UVM |
| [`d8-fifo`](d8-fifo/) | 8 | **Capstone 2**: a FIFO with backpressure, where the scoreboard cannot be a table | everything | UVM · z3 |

Three of the table —`d5b`, `d6-bins` and `d6-semillas`— are the *coverage
closure* cycle done by hand: measure a distribution, write the directed case
that fills the missing bin, and accumulate coverage with a multi-seed
regression. The course tells it twice; here you do it.

[`d7-final`](d7-final/) is different from the others, and on purpose: **there is
no file with a hole in it**. There is a DUT that is not the VTALU —an APB slave
with four 32-bit registers—, its specification, and a blank page. The checker
goes in stages —monitor, driver, scoreboard, coverage— and each one prints its
`STAGE N OK`, so you can finish one at a time.

[`d8-ral`](d8-ral/) is the one from the optional unit and it goes **after** the
capstone: it reuses the same DUT and the same testbench, and adds the register
model on top. It also goes in stages, and the second one is marked by two
`uvm-core` sequences nobody wrote.

And the last one, [`d8-fifo`](d8-fifo/), is the **second capstone**, for whoever
already handed in the first. The protocol is simpler —no addresses, no wait
states— and it is still harder: the APB scoreboard could be a four-row table,
and a FIFO's cannot, because a FIFO has order and occupancy. The `+BUG=1` bug is
in a **flag**, not in the data: a scoreboard that only compares what comes out
of `rd_data` passes green with a broken DUT.

```sh
cd code/ejercicios/d1
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

## How they are put together

Each directory holds **only the files you are going to touch**. The rest of the
testbench comes from the corresponding section, by reference: the `+incdir` in
`run.sh` put this directory first, so your version of a file wins over the
section's. Nothing you do here breaks the course examples.

`SOLUCION=1` runs the solution without overwriting your file: in the ones that
use UVM it adds a `+incdir+solucion` ahead of everything, and in the other four
it puts the `solucion/` prefix on the sources it compiles.

The exception is `d7-final`: there is no section the rest comes from, because the
rest **is** the exercise. The only thing that comes done is the DUT, `top.sv`
and the stimulus module used to test the monitor. And `d8-ral` is the inverse
case: what it is missing comes from two places at once —the testbench, from
`d7-final/solucion/`; the adapter and the tests, from `code/u9/ral/`— so it is
solved with the capstone already done.

Eleven use UVM: the first compilation takes ~1 min 30 on a 12-core laptop and
~4 min on a free Codespaces; the two capstones take ~2 min. **The following ones
are 15 seconds on either**, if you have `ccache` installed — `run.sh` detects it
by itself. The time for each one is in its README.

The four that do not use UVM —`d1`, `d1b`, `d2` and `d5b`— run without waiting
for anything. `d1b` is also the only one that compiles with `--trace`: it leaves
`ondas.vcd` alongside, because the waves *are* the exercise. The five that
randomize with constraints —`d5b`, `d6-bins`, `d6-semillas`, `d7-final` and
`d8-fifo`— also need **`z3`**: without it `randomize()` returns 0 silently. See
[`docs/verilator.md`](../../docs/verilator.md) (in Spanish).

## For whoever teaches it

`make ejercicios` runs the fifteen **solutions**. It does not check that a
student solved one: it checks that the fifteen are still solvable when the
course code changes.

The four from day 6, the two from day 7 and the two from day 8 compile a whole
testbench with UVM: they are the slowest.

Two of them have the seed **pinned**, and it is on purpose: `d6-bins` nails it in
`run.sh` (`export SEED=7`) because it needs the 60 random operations *not* to
fill the bin that has to be closed, and `d6-semillas` walks it from 1 to 5 in
`regresion.sh` because it needs the five to give different results. Without
pinning them, both would be flaky — which is exactly the defect they teach you
to avoid.
