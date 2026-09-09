<!-- es-sha: 26c2944ba150 -->
# Day 3 — a new test without touching the structure

The testbench already comes with the `env` separating structure from stimulus.
`random_test` and `add_test` already exist. The one that multiplies is missing.

## What is asked

1. **`mult_tester.svh`** — a tester that extends `random_tester` and always returns
   `mul_op` in `get_op()`.
2. **`mult_test.svh`** — a `uvm_test` that tells the factory that when
   somebody asks for a `base_tester` it should hand over your `mult_tester`, and that creates the `env`.
3. **Do not touch `env.svh`.** That is the whole point: the structure of the testbench
   never finds out that the stimulus changed. `run.sh` checks that with
   `intocables.sha` before compiling: instantiating your `mult_tester` there by
   hand also makes the test pass, and then the exercise --the
   `set_type_override`-- never happened.

Done when `bash run.sh` prints `EXERCISE OK`.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

`env.svh` instantiates a `chequeo` component that is not part of the course: it watches the
DUT bus and reports a `uvm_error` if an operation goes past that is not a
multiplication. That is why the exercise marks itself.

## How long it takes

This exercise compiles the whole of UVM. Measured with Verilator 5.052:

| | 12 cores | 2 cores (free Codespaces) |
|---|---|---|
| the first time | ~1 min 30 | ~4 min |
| the following ones, with `ccache` | ~15 s | ~15 s |

A `ccache` hit is copying a file, so the second compilation takes the
same on any machine. Install it before starting —the `run.sh` detects it
on its own— or use Codespaces, which already brings it.

## What it practises

UVM tests, components and phases, and above all the factory override of the
`env` section. Compare it with day 2: there the type was picked in the code of the testbench, here
the factory picks it and the testbench does not even find out.

Look at the coverage too: with nothing but multiplications it drops to 26 %. A
focused test covers less — that is why several are needed, and that is why it matters that
adding them is cheap.
