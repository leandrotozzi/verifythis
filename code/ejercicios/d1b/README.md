<!-- es-sha: f483d9e5167a -->
**English** · [Castellano](README.es.md)

# Day 1 — the waves: the log is not enough

The debug appendix says that the waves are the tool **47 % of the work** gets
done with. This is the exercise where that gets practised: it is the only one
of the course that is **not solved by reading the log**.

Run:

```sh
bash run.sh
```

The simulation aborts with **a single line**:

```
FAILED: A: e5  B: 0  op: mul_op result: fe01 ovf: 0
```

And that is where what the log gives you ends. `e5 * 00` is `0`, not `fe01`. The scoreboard
is right, the DUT is healthy, and the number that came out does not belong to this operation.

## What is asked

### 1 · Read the waves

The `run.sh` always compiles with `--trace`, so the run leaves **`ondas.vcd`**
next to it. Open it:

```sh
gtkwave ondas.vcd     # or surfer, or whatever viewer you use
```

Put `clk`, `start`, `op`, `A`, `B`, `done` and `result` in the viewer, and answer
two questions by writing the times into **`respuesta.txt`**, one per line, in
picoseconds and without the unit:

1. At which instant does `done` go up for the **first time**?
2. At which instant does `done` of the **first multiplication** go up? (look for the
   first stretch with `op = mul_op`, or `start_mult` at 1)

```
# respuesta.txt
1234
5678
```

Both numbers come out of the viewer and from nowhere else: they are not in the log.
They are in picoseconds because the `run.sh` compiles with `--timescale 1ps/1ps`;
without it they would depend on the simulator's default.

> While you are there, look at `A` and `B` at the instant of the second answer and
> compare them with the ones the `FAILED` printed. That is the answer to *why*.

### 2 · Fix the BFM

With the waves in sight it shows on its own: `done` of a multiplication arrives on the
**fourth edge** after the `start`, and the one of the other operations on the first. The
`send_op` of `vtalu_bfm.sv` **counts edges** instead of waiting for the handshake,
so it returns too early and the next stimulus overwrites `A` and `B` while
the multiplier is still computing.

It gets fixed with **one line**. The TODO is in the file.

Done when `bash run.sh` prints `EXERCISE OK`.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

The checker goes in stages and each one prints its `STAGE N OK`, like the capstone.
The two times are measured **off the `ondas.vcd` that same run has just left**:
what it asks you for is always what the waves you have open say, whatever order
you run things in.

Watch out for that in stage 2: when you fix the BFM, **the second number moves**.
With the handshake properly waited for every one-cycle operation takes one edge
less, so the first multiplication starts —and closes— earlier (830 ps become
650 ps). Open the waves again and update `respuesta.txt`: that shift is the
lesson of the exercise, seen in the viewer.

## How long it takes

It does not use UVM: it compiles and runs in **seconds**, without `ccache` and without `z3`.

## What it practises

- **Opening a `.vcd` and reading a time.** It sounds trivial until you need it.
- That a log says *that* something failed and almost never *why*. The `FAILED` of this
  exercise is correct, complete, and not enough.
- The golden rule of the debug appendix: **suspect number one is never the
  DUT**, it is the testbench watching it.
- And the protocol lesson that comes back in the day 7 capstone, with the APB wait
  state: **do not count cycles, wait for the handshake.** The day the DUT
  takes one more cycle, a testbench that counts does not find out.
