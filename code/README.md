<!-- es-sha: 5409279503c8 -->
**English** · [Castellano](README.es.md)

# Code examples

One directory per unit —`u2/` to `u9/`—, and inside it one directory per example,
named after the section that uses it. Each example is **self-contained on
purpose**: you can copy `code/u4/env/` somewhere else and run it as is. That is
why `vtalu_bfm.sv`, `vtalu_pkg.sv` and company show up repeated across units — it
is not duplication waiting to be cleaned up, it is that each example shows its own
version of those files as the testbench evolves.

| | Unit | Examples |
|:--|:--|:--|
| `u2/` | The testbench without UVM | `convencional`, `interfaces-bfm` |
| `u3/` | The OOP that UVM takes for granted | `clases`, `polimorfismo`, `estaticas`, `parametricas`, `factory`, `tb-en-objetos` |
| `u4/` | UVM enters | `tests`, `components`, `env`, `reporting` |
| `u5/` | How the components talk | `varios-objetos`, `analysis-ports`, `threads`, `put-get` |
| `u6/` | The data | `jerarquias`, `transactions` (+ `constraints`) |
| `u7/` | The reusable testbench | `agents`, `callbacks`, `sequences` (+ `virtual`) |
| `u8/` | The other half | `assertions` |
| `u9/` | RAL — the optional unit | `ral` |

There is no `u1/`: the code of unit 1 is the DUT, which lives in `code/vtalu_dut/`
because every unit uses it.

`u9/ral` is the exception to the *self-contained* rule, and on purpose: it brings
neither DUT nor testbench, it takes them from the capstone
(`ejercicios/d7-final/`) through `+incdir`. It is the way of saying in code what
the unit says in the slides — RAL is a layer on top of a testbench that already
works, not a different testbench.

## The language of `code/`

**Everything in here is in English**, and that is deliberate: comments,
`TODO(exercise <dir>)`, the messages the graders print, the `$display` calls that
narrate an example, and the headers of the `run.sh` files.

There is a single reason and it is worth stating in full. The course is taught in
two languages, and the slides do not paste the code: they **include** it with
`{{code:}}`. If the comments were in the language of the course there would have
to be two copies of `code/` —the examples twice, the exercises twice, the
solutions twice— and the day one of them is fixed the other stays broken with
nothing to warn you. Writing it once, in English, is what makes both versions of
the course show and run exactly the same code. And it happens to be the language
the student will write comments in at work.

**The only exception are the `README` files**, which are the statement of the
exercise and not documentation of the code: there there are indeed two,
`README.md` in English and `README.es.md` next to it. The English one is the one
called `README.md` because it is the only one GitHub renders when you enter a
directory, and whoever lands here from a search almost always reads in English —
the same reason the README at the root goes the other way round from the rest of
the repo. It is still written in Spanish: the source is the `.es.md` and
`npm run check` verifies that the pair has not drifted apart — see
`tools/lint-i18n.mjs`.

Identifiers are a different matter and are not translated: UVM's nomenclature is
already English (`driver`, `scoreboard`, `env`), and the few exceptions in Spanish
—the fernet tray of `u6/jerarquias`, the `chequeo` of the graders,
`clase_`/`modulo_` of `u7/agents`, which on top of that cannot be called
`class_`/`module_` because those are keywords— are metaphors of the course and are
explained on the slide.

## Requirements

**Verilator ≥ 5.050** — free, no licence. Covergroups landed in that version:
before it, functional coverage was not measured. What works and what does not,
with the coverage number of each example, in
[`../docs/verilator.md`](../docs/verilator.md).

UVM 2020.3.1 (Accellera `uvm-core`, IEEE 1800.2-2020) is downloaded separately,
once: `make uvm` (or `make` does it by itself). Verilator has supported it
officially since 5.052.

## Running an example

```sh
make u3/tb-en-objetos             # from the root of the repo
cd code/u3/tb-en-objetos && ./run.sh
```

Every example directory brings:

| File        | What it is |
|-------------|--------|
| `run.sh`    | compiles with Verilator and simulates |
| `dut.f`     | DUT sources |
| `tb.f`      | list of testbench sources |

## The negative test: `make mutante`

That an example **runs** says nothing about whether it **checks**. A scoreboard
with the analysis port left unconnected, a `uvm_error` that can never fire, a
covergroup whose bin is trivial: all three pass green and prove nothing.

That is why the DUT brings an injectable mutation. With `+VTALU_BUG` —which
`common.sh` sets when it sees `VTALU_BUG` in the environment— bit 0 of `result`
comes out flipped for every operation, and **the example has to fail**:

```sh
make mutante                                    # the three without UVM: seconds
make mutante MUTANTES="u4/tests u7/sequences"   # the UVM ones: minutes
cd code/u2/interfaces-bfm && VTALU_BUG=1 ./run.sh    # by hand, just one
```

It is the only difference between "the example runs" and "the example proves".
It is the same liberty `apb_regs.sv` takes with its `bug_en`, and it is declared
in the comment of `vtalu_dut/vtalu.sv`.

The examples of `u7/callbacks`, `u8/assertions`, `u8/dpi` and `u9/ral` bring their
own mutation inside the `run.sh` —the bit flipped by the callback, the `+BUG=1` of
the property, the `+GOLDEN_BUG` of the C model, the `+MAL` of the RAL model— and
check the result themselves. That is why they are not in `MUTANTES`.

`code/verilator/` holds what the `run.sh` files share: the flags, the DPI shim
that makes UVM compile, and four minimal repros of Verilator limitations —the
transition bins and `binsof`/`intersect`, the covergroup options (`at_least`,
`weight`, `merge_instances`), `solve ... before` and `randomize() with` over a
field with `dist`— explained in `docs/verilator.md`. The fifth,
`repro-vif-task.sv`, documents a bug that **has already been fixed** in Verilator
5.052 and stays as dated evidence.
They are run by hand; `make matrix` only runs the `run.sh` of `code/u*/`.

The examples with several variants (`u3/polimorfismo`, `u3/estaticas`,
`u3/parametricas`, `u5/varios-objetos`, `u5/threads`) have one subdirectory per
variant, each with its own `run.sh`.

`u8/assertions` is the only example whose `run.sh` compiles with `--assert`, and
the only one that runs twice: once clean and once with `+BUG=1`, which is what
makes the property shout.

`u6/transactions/constraints/` is the exception to the self-containment rule: they are the four
experiments of the Constrained Random unit, without UVM and without DUT, with a
single `run.sh` that compiles the four tops. They compile in seconds and can be
run on their own.

`u7/sequences/virtual/` is the other one: the **virtual sequence**, which needs the two
VTALU with both agents **active** and therefore a different `top.sv` and `env.svh`.
Instead of copying the whole example, that directory has only the five files that
change and brings the rest through `+incdir`. What it teaches is exactly the size
of the diff.

`u7/callbacks/` is the third, and for the same reason: the diff against `u7/agents`
is **two lines** of the driver —`` `uvm_register_cb `` and `` `uvm_do_callbacks ``—
plus the callback and the test that hangs it. Copying the 900 lines of the example
next door to show two would hide precisely what we want to show, so its `tb.f`
puts `+incdir+tb_classes` **before** `+incdir+../agents/tb_classes` and only
`driver.svh` beats the one from the other section. It is the same mechanism the
exercises use.

## Expected output files

The `.txt` files the slides show (`u4/tests/output.txt`, the ones of `u5/threads`, the ones of
`u4/reporting`) **are not simulation garbage**: they are the real output of running
the example, captured on purpose so that the slide shows the same thing the
student is going to see in their terminal. They are regenerated with:

```sh
sh tools/regen-outputs.sh          # all of them
sh tools/regen-outputs.sh u4/reporting     # only the ones that match
```

It is not part of `make`: it is run by hand when the version of UVM or of the
simulator changes. Each build with UVM takes several minutes.

`u4/tests/output.questa` is different: it is the reference run with Questa and UVM
1.1d, from before the Questa flow was taken out of the repo. It is no longer shown
on any slide — it stays as **witness** that the comparison chain closes (Questa
1.1d → Verilator + UVM 1.2 → Verilator + UVM 2020.3.1). Do not delete it, but do
not update it either.

> The `.txt` files of u4/reporting come from a scoreboard with a bug put there on
> purpose (`add_op` adds too much), which is what lets the section show what a
> `uvm_error` looks like and how it is silenced. `scoreboard2.txt` is the same
> run with `set_report_severity_action_hier()` in place; the script does it by
> touching `env.svh` and leaving it as it was.
