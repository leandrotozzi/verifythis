<!-- es-sha: c7e0c385834e -->
# Day 5 — the scoreboard screams and the DUT is healthy

The testbench already uses transactions. Run:

```sh
bash run.sh
```

The scoreboard reports `FAIL` on almost every operation. **The DUT is fine** — it
is the same one that has been passing since the spec. The bug is in the
testbench, in this directory.

## What is asked

1. Find it. The messages from the monitor are `UVM_HIGH`, so by default they are
   not shown:

   ```sh
   bash run.sh +UVM_VERBOSITY=UVM_HIGH
   ```

   Compare what the monitor says it saw with what the scoreboard compares.
2. Fix it.

Done when `bash run.sh` ends with `UVM_ERROR : 0`. You do not have to check
anything by hand: ever since `run_sim` reads the *Report Summary*, an example
with UVM that reports errors does not pass.

## How to run it

```sh
bash run.sh                          # with your files
bash run.sh +UVM_VERBOSITY=UVM_HIGH  # with the debug messages in sight
SOLUCION=1 bash run.sh               # with the ones in solucion/, to compare
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

## If you get stuck

The two appendices at the end of the deck are written for this exercise:

- **The debug toolbox** — the *"which one to use according to the symptom"* table
  has the row `the scoreboard screams on every one`, and it says what to look at
  it with.
- **The twenty silent traps** — the catalogue of everything that compiles, runs
  and lies. The cause of this bug is one of the nineteen.

The exercise can be done without having seen reporting: it is enough to have the
symptom slide open alongside.

## What it practises

Verbosity and reporting, monitors and analysis ports, transactions. And the
underlying lesson, which is a matter of craft and not of syntax: **when the
scoreboard screams, suspect number one is not the DUT.** A monitor that samples
badly invents failures that do not exist, and makes you lose days.
