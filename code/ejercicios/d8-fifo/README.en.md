<!-- es-sha: bc959a01a188 -->
# Capstone 2 · a FIFO with backpressure

> **This gets done after the `d7-final`.** Not because it is harder to
> write —the protocol is simpler, there are no addresses and no wait states—
> but because whoever already did the APB arrives here with a pattern in their head, and
> **the pattern is not enough.**

```sh
cd code/ejercicios/d8-fifo
cat spec.en.md
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

## Why this second final exists

The DUT of the APB capstone is a **slave with no useful memory**: you write an
address, you read that address, and the scoreboard can be a table of four
rows. That is most of the DUTs you run into in the first year, and that is why
it goes first.

This one is not. A FIFO has no addresses: it has **order** and it has **occupancy**.
The reference model is a queue with state, and the flags that have to be
predicted depend on everything that happened before. There is no table that will do.

The difference shows up in one line of the checker:

```
con +BUG=1 almost_full se levanta un lugar tarde, y tu scoreboard no dijo nada.
Los datos salen bien igual.
```

A scoreboard that compares only what comes out of `rd_data` closes six of the
seven rows of the plan and **passes green with the DUT broken**. That is the exercise.

## What is given done, and does not get touched

| File | What it is |
|---|---|
| `rtl/sync_fifo.sv` | the DUT. With `+BUG=1` it runs `almost_full` one place off |
| `top.sv` | two FIFOs: yours and the one of the ordinary module |
| `fifo_stim_module.sv` | the ordinary module: twelve cycles, without one line of UVM |
| `spec.en.md` | the spec, the small print and the verification plan |
| `run.sh` | the checker, in stages |

## What you write

In this order, which is the checker's and the one of the appendix *From the VTALU to a real
bus*:

1. **`fifo_if.sv`** — the pins, the clock, `reset()`, `ciclo()` and the monitor
   hook.
2. **`fifo_pkg.sv`** — the package that includes your classes, with `DEPTH`, `AF` and
   `AE` written **only once**.
3. **`tb_classes/`** — the transaction, the monitor, the driver, the agent, the env,
   the scoreboard, the coverage, the sequences and the tests.

## The four stages

- **1 · The monitor.** A **passive** agent on the FIFO of the ordinary module,
  to see the twelve cycles with activity. Without a driver. Careful with `rd_data`, which arrives
  one cycle late.
- **2 · The driver.** A directed sequence that **fills it to the top and goes past it**,
  and then empties it and goes past that. Both edges in a single test.
- **3 · The scoreboard.** The reference model with state. The checker runs it
  twice: against the healthy DUT it has to keep quiet, and with **`+BUG=1`**
  it has to scream.
- **4 · The coverage.** The `covergroup` with the seven rows of the plan: more than
  20 points, 90 % covered.

## Hints, in order of usefulness

- **The scoreboard is two queues, not one.** One is what the FIFO has inside;
  the other, what has already been read and has not come out of `rd_data` yet. With a single one you
  cannot model the one-cycle latency.
- **Check the flags before applying the cycle.** They describe the state
  before the edge. If you apply first and compare afterwards, you are going to get one
  error per cycle and you are going to blame the DUT.
- **The order of the update is the small print.** First look at whether the
  read takes something out —that frees a place—, and only then whether the write goes in.
  The other way round, the simultaneous one with the FIFO full is going to give you a lost piece of data the
  DUT did not lose.
- **The driver does not look at the flags.** It sends what the sequence asked for, even if
  it is full. A driver that censors itself covers up precisely the case that has to be
  verified — and leaves the bin `escribe_llena` at zero forever.
- If the `check_phase` tells you *"N data were left that never came out"*, almost
  always it is that the test ended one cycle too early. The data of the last
  read comes out **afterwards**: a cushion is needed, which is the `drain_time` of
  day 3.
- If the coverage does not get there, do not add cycles: **bias the `dist`** of the
  transaction so it writes more than it reads. With 50/50 the FIFO stays
  hovering around the middle and does not touch any edge. It is the lesson of day 5.

## And afterwards

`ci/regresion.yml` of the `d7-final` works for this one just the same: change its `DIR` and
you have the regression of this FIFO running on its own, with the accumulated coverage of N
seeds.

## What it practises

Everything from the first capstone —interface, active and passive agent, `config_db`,
sequences, tests, covergroup— plus what the first one could not ask for: a
**reference model with state**, the prediction of **control outputs** and
not only of data, and a one-cycle latency between the request and the response.
And one more thing, which is not about UVM either: **knowing when your scoreboard is not
checking what you think it is checking**.
