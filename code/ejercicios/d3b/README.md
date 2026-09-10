<!-- es-sha: b38d22aba396 -->
**English** · [Castellano](README.es.md)

# Day 3 — the `uvm_error` that says nothing

Day 1 started with this line:

```
FAILED: A: e5  B: 0  op: mul_op result: fe01 ovf: 0
```

and with the observation that a log says **that** something failed and almost
never **why**. This is the exercise where that gets fixed, from the side of
whoever writes the log.

The testbench is the whole one from the *The whole env* section. The
`scoreboard.svh` that is here is **right**: it catches every mismatch. And it is
useless: when it fails, it says `FAILED` and nothing else.

```sh
bash run.sh
```

## What is asked

**`scoreboard.svh`**, two changes, and neither of them changes what the
scoreboard *checks*:

1. **That the `uvm_error` says which one failed.** This is the log contract, and
   the checker verifies it against the operation that really failed:

   | What | How |
   |---|---|
   | `A` and `B` | **two** hex digits — `%02h` |
   | the operation | its name, `add_op`, `mul_op`… — `%s` over `.name()` |
   | the DUT's result and the one you predicted | **four** hex digits each — `%04h` |

   The order and the text around them are yours. What is checked is that the
   five values are **on the same line**.

2. **That the comparison that passes gets printed too**, with the word `PASS`
   and at verbosity **`UVM_HIGH`**. It goes in the `else` of the same `if`.

Done when `bash run.sh` prints `EXERCISE OK`.

## How it is run

```sh
bash run.sh              # with your file
SOLUCION=1 bash run.sh   # with the one in solucion/, to compare
```

`run.sh` runs the same testbench **three times**, and each one grades one thing:

1. with `+VTALU_BUG` —the DUT comes out broken on purpose— so that your
   `uvm_error` fires and what it says can be read;
2. without the bug and with the usual verbosity: the `PASS` must **not** appear;
3. without the bug and with `+UVM_VERBOSITY=UVM_HIGH`: now it does, **once per
   comparison**.

`chequeo.svh`, `env.svh`, `vtalu_pkg.sv` and the two `.f` are not touched: the
`shasum -c intocables.sha` catches it before compiling. `chequeo.svh` is the one
that watches the same bus you do and knows which was the first operation that
failed.

## How long it takes

It compiles the whole of UVM: ~1 min 30 the first time on a 12-core laptop, ~15 s
the next ones with `ccache`. Writing it is ten minutes.

## Why the verbosity, and not deleting the `PASS`

A scoreboard that only speaks when it fails looks cleaner, and it is the one that
loses you the morning: when operation 700 fails, what you need to know is what
happened in 699. That is why the `PASS` is written **and** hidden: `UVM_HIGH`
takes it out of the everyday log and leaves it one `+UVM_VERBOSITY=UVM_HIGH`
away for the day it is needed.

That is the difference between **verbosity** and **severity**, which is half of
the *Reporting* section: severity says how serious it is, verbosity says how much
you feel like reading it today.

## What it practises

`uvm_error` and `uvm_info` with `$sformatf`, the verbosity levels,
`+UVM_VERBOSITY` from the command line, and row 10 of the closing
self-assessment: *making a scoreboard that fails say something more than
"it failed"*.
