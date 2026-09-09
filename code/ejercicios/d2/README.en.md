<!-- es-sha: ecee5ce5b4dc -->
# Day 2 — a tester that only multiplies, without touching the one already there

The testbench is the one from *A testbench without a single module*, in classes. Today `tester` sends
random operations; we want one that sends only multiplications, **without copying
and pasting the whole class**.

## What is asked

1. **`mult_tester.svh`** — write the class: it extends `tester` and redefines
   `get_op()` to always return `mul_op`.
2. **`testbench.svh`** — make `tester_h` a `mult_tester`.
3. And it is going to carry on sending random operations. **That is where the exercise is**:
   look at `tester.svh`, and remember polymorphism.

Done when `bash run.sh` prints `EXERCISE OK`.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

## How long it takes

It does not use UVM —the testbench is the object-oriented one, without the
library—: it compiles and runs in **seconds**.

## What it practises

Inheritance, polymorphism and `virtual` on top of the object-based testbench.
It is the same problem the day 3 exercise solves with the factory: doing it
by hand first is what afterwards explains what the factory is for.
