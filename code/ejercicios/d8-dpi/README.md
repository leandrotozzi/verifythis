<!-- es-sha: 2fb866f85dfa -->
**English** · [Castellano](README.es.md)

# Day 8 — the reference model in C

The testbench is the whole one from the DPI section and **not one line of it gets
touched**. The only file of this exercise is `vtalu_golden.c`: the reference
model the scoreboard consults instead of predicting in SystemVerilog.

Three operations come done —they are the pattern— and two are missing.

## What is asked for

1. **`SUB_OP`** — the subtraction has **two halves**, and the second one is the
   one everybody forgets: 8-bit operands into a 16-bit result, so `a - b` wraps,
   and the **borrow** (`a < b`) is the other half of the answer the scoreboard
   compares. It goes out through `*ovf`.
2. **`MUL_OP`** — the full product, and the mutation that proves the path is
   alive: with `mutar` at 1 the model has to **lie**. Truncating to 8 bits is
   enough.

Done when `bash run.sh` prints the three stages and ends with `EXERCISE OK`.

## The checker's three stages

| | What it runs | What it proves |
|:--:|---|---|
| **1** | healthy DUT against your model | that your model is right: 0 `UVM_ERROR` |
| **2** | **mutated** DUT (`VTALU_BUG=1`) against your model | that the scoreboard is **really** asking you |
| **3** | healthy DUT against your **mutated** model (`+GOLDEN_BUG`) | that your mutation exists: a scoreboard that never saw an error is not tested |

Stage 2 is what makes the exercise worth it. A model returning some fixed thing
could pass stage 1 by accident if the stimulus were poor; with the DUT lying on
bit 0, there is no way of passing it without having computed.

## The trap you cannot see

`extern "C"` is not decoration. Verilator hands user sources to the **C++**
compiler, and without the guard the symbol comes out mangled: the link fails with
an *undefined reference* to a function that is right there, written, two lines
above. It is DPI's number one failure mode with Verilator and that is why the
skeleton comes with it already in place.

The second one: the opcodes are written **twice** —the `enum` of this file and
the `operation_t` of `vtalu_pkg.sv`— and nobody compares them. That is the tax of
DPI, and it is the first thing to look at when *every* comparison fails at once.

## How to run it

```sh
bash run.sh              # with your file
SOLUCION=1 bash run.sh   # with the one in solucion/, to compare
```

## How long it takes

It compiles the whole of UVM, like the rest of the day 8 exercises:

| | 12 cores | 2 cores (free Codespaces) |
|---|---|---|
| the first time | ~2 min | ~5 min |
| the following ones, with `ccache` | ~15 s | ~15 s |

Touching only the `.c` recompiles **one** file: the rest of the binary is already
there. That is half the advantage of having the model outside, and the other half
is that the algorithm team wrote it and you did not.

## What it practises

DPI-C both ways: the return value and the `output` argument through a pointer,
the `extern "C"` guard, and mutation as proof that the path is connected. The
underlying point is the section's: for a DUT with real arithmetic —a DSP, a
codec, a crypto engine— **the model in C already exists**, the team that signed
the spec wrote it, and rewriting it in SystemVerilog means maintaining two models
and debugging the difference between them.
