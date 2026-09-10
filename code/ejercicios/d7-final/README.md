<!-- es-sha: 0f4ec16a3c7e -->
**English** · [Castellano](README.es.md)

# Day 7 — the capstone: verify the `apb_regs`

The other thirteen exercises with a statement gave you a file with a hole in it. This one gives you a DUT,
a spec and nothing else. **You write the testbench, all of it**, and that is the only
difference between *"I did the course"* and *"I know how to do it"*.

The DUT is an **APB3** slave with four registers. It is not an ALU: it has
addresses, two phases per transfer, a wait state and an error response. It is
what you are going to run into on Monday, and it is exactly the jump the
appendix *From the VTALU to a real bus* promises.

## What you are given, and does not get touched

| | |
|---|---|
| [`spec.en.md`](spec.en.md) | **the specification**: pins, protocol, register map, the small print and the verification plan |
| `rtl/apb_regs.sv` | the DUT |
| `top.sv` | the **two** slaves, each with its interface, and the `config_db` |
| `apb_stim_module.sv` | the ordinary module, without one line of UVM, that drives the second bus |
| `run.sh` | the checker, in stages |

The second bus is there so you can write the **monitor before the driver**,
which is the field advice of the appendix: if you cannot *see* the bus, you cannot
verify anything — not even somebody else's stimulus.

## What you write

In this directory, starting from a blank sheet:

```
apb_if.sv           the interface: pins, clock, the protocol and the monitor hook
apb_pkg.sv          the package that includes everything below, in order
tb_classes/*.svh    transaction, config, driver, monitor, agent, scoreboard,
                    covergroup, env, sequences and tests
```

## The deliverables, in order

The checker goes in stages and each one prints its `STAGE N OK`. It can be
finished one at a time, and that is the way to do it: each stage leans on the previous one.

**1 · The monitor.** `apb_if.sv` with the pins of the spec, the `apb_transaction`,
the `apb_monitor`, a **passive** `apb_agent` on `stim_bfm`, the `env` and a
`monitor_test` that raises the objection and waits. Without a driver and without a scoreboard.
The ordinary module does **eight** transfers: you have to see all eight, and
not one more.

**2 · The driver.** The tasks of the protocol inside `apb_if.sv`, the
`apb_driver`, the sequencer, the **active** agent on `bfm`, a directed
sequence and a `smoke_test`. It has to write and read the four registers: it is
row 1 of the verification plan.

**3 · The scoreboard.** The `apb_scoreboard`, which is the DUT modelled in software:
the same four registers, the same rules, no signals. And a
`random_test` with a random sequence. The checker runs it **twice**: once
against the healthy DUT —it has to close at 0 `UVM_ERROR`— and another with `+BUG=1`, which
takes the `CTRL.EN` gate off the DUT. There it **has to scream**: a scoreboard that
has never seen an error is not tested.

**4 · The coverage.** The `covergroup` with the nine rows of the verification
plan of `spec.en.md`. The checker asks for **more than 20 points** and **90 %**
covered with the `random_test`. Rows **8 and 9 come empty**: you write them,
and the bins are called `back_to_back` and `unaligned` because the checker looks
them up by name. How a table like this gets filled in, in
[`docs/en/verification-plan.md`](../../../docs/en/verification-plan.md).

**5 · The properties.** The APB protocol checked **where it happens**, inside
`apb_if.sv`: SETUP lasts one cycle, the payload does not move until the transfer
ends, ACCESS is held until the handshake. They are compiled with `--assert` —the
`run.sh` already passes it— and they report with `` `uvm_error("SVA", ...) `` in the
`else`. The checker runs the ordinary module with **`+BUG=2`**, which moves its
`PADDR` in the middle of ACCESS: the DUT answers at the new address, the monitor
reconstructs eight spotless transfers, the scoreboard has nothing to say, and the
only one that notices is the assertion. That is the day 7 argument, now on a real
bus.

Done when `bash run.sh` prints the five stages and ends with `EXERCISE OK`.

## The contract with the checker

The checker does not read your code: it reads the log. Four things have to be like this:

- The **tests** are called `monitor_test`, `smoke_test` and `random_test`.
- The **monitor** prints one line per complete transfer, with this exact
  format and with the id `MONITOR`:

  ```
  `uvm_info("MONITOR", t.convert2string(), UVM_MEDIUM)
  ```
  ```
  WR @0x04 = 0x10000000  slverr=0
  RD @0x08 = 0x00000030  slverr=1
  ```
  On a write the value is `PWDATA`; on a read, `PRDATA`.
- The **scoreboard** reports with `` `uvm_error("SCOREBOARD", ...) ``, and the
  stage 5 **properties** with `` `uvm_error("SVA", ...) ``.
- The two bins of rows 8 and 9 of the plan are called **`back_to_back`** and
  **`unaligned`**: the checker looks them up by name in the coverage database.

It is not bureaucracy: an agreed log format is what lets whoever arrives at the
project tomorrow grep your testbench without reading it.

## How to run it

```sh
bash run.sh              # with your files
SOLUCION=1 bash run.sh   # with the ones in solucion/, to compare
```

`solucion/` has the complete testbench: seventeen files, which are the same
types of class as `code/u7/sequences` plus the interface and the package. Look at it
**afterwards**, or the exercise is good for nothing.

## How long it takes

It compiles the whole of UVM, like the other ones of days 6 and 7:

| | |
|---|---|
| the first time | ~2 min |
| the following ones, without touching anything | ~6 s |
| the following ones, with `ccache` and one file touched | ~15 s |

Of those seconds, four go to the solver: the `random_test` is 400
transactions with `dist`, and every `randomize()` is a call to **z3**. Without z3
installed, `randomize()` returns 0 in silence — see
[`docs/verilator.md`](../../../docs/verilator.md) (in Spanish).

## Hints, in order of usefulness

- **Start with the monitor, not with the driver.** It is the order of the appendix and it is the
  order of the checker. With the monitor working you have eyes; without it you are
  driving blind.
- A transfer ends **on the rising edge on which `PREADY` is
  high**, not when `PENABLE` goes down. A monitor that samples any other
  edge reports too many or too few, and in stage 1 the number tells you so.
- The read has **one wait state**. Do not count it in cycles: wait for the
  handshake (`do @(posedge PCLK); while (!PREADY);`). The day the slave puts in
  three wait states, your driver does not even notice.
- If the scoreboard fails on the first read of `CTRL`, read the small
  print again: `CLR` is autoclear and **never reads as 1**.
- If it fails writing `ACC` or `STATUS`, the trap is the other way round: writing a
  read-only register does **not** give `PSLVERR`.
- If `+BUG=1` fires nothing at you, your model is not looking at `CTRL.EN` — or your
  stimulus never reads `ACC`. Both things get fixed by looking at row 5 of the
  verification plan.
- Do not invent the `covergroup`: the table at the end of `spec.en.md` has the
  rows, and the right-hand column says which bin each one is. The last two are
  empty on purpose.
- If the scoreboard fails on an odd address —`0x06`, `0x0D`— it is row 9:
  `PADDR[1:0]` is ignored, so `0x06` **is** the `SCRATCH`. A `case` on the whole
  address sends those transfers to the `default`.
- For row 8 the one who decides is the driver: if it leaves `PSEL` high at the end of
  a transfer, the next one starts glued to it. Careful with the last one of the sequence —
  if it stays chained and nobody comes, the bus is left in ACCESS forever.
- The stage 5 properties go **in the interface**, not in the testbench: there they
  see the signals without anybody passing them along, and both instances of the
  `top.sv` inherit them. And each one with its `cover property`: an assertion whose
  antecedent never happens is green without having checked a thing.
- The obvious reading of *"`PSLVERR` is valid together with `PREADY`"* —
  `PSLVERR |-> PREADY` — is **false** on this DUT: `PSLVERR` is combinational and
  is already high during the read's wait state. That rule is a `cover`, not an
  `assert`.
- Drive on the **falling** edge and sample on the **rising** one, like the whole
  BFM of the course. It is the same lesson as the two clocks of the assertions.
- **Or better: use a `clocking block`** in `apb_if.sv`, which is what gets written
  in a project. `default input #1step output #0`, and the driver stops choosing an
  edge: `cb.PADDR <= …` to drive, `cb.PRDATA` to sample. The section
  of unit 2 has the example running in `code/u2/clocking/`. The checker
  does not look at how you did it — it looks at the log —, so both ways pass; this is
  the one you are going to have to be able to defend.

## And afterwards: the regression, in your repo

When the checker gives you the four stages, the next step is not another
exercise: it is **getting this to run on its own**. `ci/regresion.yml` is a workflow of
GitHub Actions ready to copy into `.github/workflows/` of **your** repo. It runs
the same test with N seeds, merges the coverage, and leaves the number in the summary
of the job:

```
cobertura de la regresión: 118/131 bins (90.1 %)
bins que ninguna semilla llenó: unmapped_x_wr, status_x_wr, ...
```

Three variables have to be touched —where your `run.sh` is, with which test, how many
seeds— and nothing else. It compiles Verilator from source and caches it, because the package
of the distro is old and the covergroups came in on 5.050.

That number going up commit by commit is **coverage closure**, which is what
a verification team does every day. And that a student can have it for free
on a public runner is a direct consequence of the simulator being free: there
is no floating licence to ask anybody for.

If you work inside a fork of the course, `make regresion EJEMPLO=... N=...` does
the same on your machine and besides writes an HTML report with the open bins.

## What it practises

Everything. It is the only exercise of the course where there is no previous structure: the
transaction, the interface with the protocol inside, the active agent and the passive one,
the `config_db` with two scopes, the scoreboard as a reference model, the
covergroup as a measured verification plan, the sequences, the tests and the
protocol properties. And two more things, which are not about UVM: **reading a
spec and distrusting it**, and **writing two rows of the plan** that the spec
promises on a loose line and nobody had measured.
