<!-- es-sha: 9cb77801ad41 -->
**English** · [Castellano](README.es.md)

# Day 6 — three planted bugs, and none of them looks like the others

The other exercises give you a file with a hole and tell you what to write. This
one gives you a testbench **that is already written** and does not work, and does
not tell you where.

It is the exercise that looks like your first month on the job.

The testbench is the whole one from the sequences section. Three of its files
were copied here with **one bug each**, and all three fail differently:

| | File | How it shows up |
|:--:|---|---|
| **1** | `driver.svh` | **it hangs**: the log stops and the simulation dies on `[PH_TIMEOUT]` |
| **2** | `default_seq_test.svh` | **it ends at `t=0`** and says PASS, without having sent anything |
| **3** | `random_sequence.svh` | **it lies in green**: `add_test` passes, coverage even goes up, and the stimulus is not the one it says |

## What is asked for

Fix all three. The checker tells you **which** of the three is still broken and
how it shows; which line it is, is the exercise.

Done when `bash run.sh` prints the three stages and ends with `EXERCISE OK`.

## Where to start

The debug toolbox of the appendix is exactly for this, and the *"which one to use
according to the symptom"* table has all three:

- **It hangs** → `+UVM_TIMEOUT=2000000,YES` so you do not wait forever, and then
  `+UVM_OBJECTION_TRACE` to see who is left holding on. The `run.sh` already
  passes the timeout: with no ceiling, a hung testbench hangs the CI too.
- **It ends at t=0** → `+UVM_OBJECTION_TRACE`. If nobody raises it, the phase
  ends right away and **there is no error**: there is nothing to complain about.
- **It lies in green** → `+TOPOLOGY` is the right reflex… and here it **is not
  enough**, because what got built wrong is a `uvm_object` and the tree only
  shows `uvm_component`. The tool that works is reading the `command_monitor`
  log with `+UVM_VERBOSITY=UVM_HIGH` and looking at **what went out on the bus**.

All three bugs are catalogued in the silent traps appendix. If you get stuck,
you are allowed to read it: the list of traps exists precisely so that the second
time it takes you five minutes.

## What NOT to do

The three files are the course's own with one line changed each. There is no need
to rewrite anything, nor to add classes, nor to touch `tb.f`. If your fix is more
than three lines in total, you are solving a different problem.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

## How long it takes

It compiles the whole of UVM, like the rest of the day 6 exercises:

| | 12 cores | 2 cores (free Codespaces) |
|---|---|---|
| the first time | ~2 min | ~5 min |
| the following ones, with `ccache` | ~20 s | ~20 s |

## What it practises

Debugging, which is what a verification engineer does most of the day and what no
other exercise of the course practises on its own. And one idea that orders
everything else: **the three failure modes of a UVM testbench do not look like
each other**. One hangs and shows up at once; the other two pass in green, and
those are the ones that cost weeks.
