<!-- es-sha: b4d1f9cb7c30 -->
# For teachers

*Verify This!* is written as **seven days of class** —plus an **optional day
8**, after the wrap-up— which is how a corporate course is delivered, and not
how a university subject is. This page maps it onto a **15-week term**, says
what can be dropped, and what to assess in each midterm.

Everything you need is already in the repository and marks itself: the **15
solutions** (`make ejercicios`), the **bank of 45 questions**
([`exam-bank.md`](exam-bank.md)), the capstone with its stage-by-stage marker,
and the **self-assessment rubric** at the end of day 7.

## How to cite it

The repository ships [`CITATION.cff`](../../CITATION.cff), so GitHub's *Cite
this repository* button generates the citation on its own, in APA or BibTeX. The
material is under **CC BY 4.0** and the code under **MIT / Apache-2.0**: it can
be printed, cut, reordered, translated and taught —for money too— with the
single condition of citing the source. See [`LICENSE`](../../LICENSE).

## The number to look at first

The seven days are **≈ 30 h 30 of class**; with the optional day 8, ≈ 34 h 30. A
15-week term with 2 h of theory is **30 h**: it fits, but barely, and only if
the lab runs separately. The map below assumes the normal format of a subject
with practical work:

> **2 h of theory + 2 h of lab a week, 15 weeks.**

With fewer hours something has to go, and the section [*What can be
skipped*](#what-can-be-skipped) says what, in what order, and what each cut
costs.

## The 15 weeks

Each row is one class. The *Lab* column is the exercise that marks itself: the
student is done when `bash run.sh` prints `EXERCISE OK`, so the teacher marks no
code by hand until the capstone.

| # | Theory (2 h) | Lab (2 h) |
|:--:|---|---|
| 1 | **U1** · Trends · What UVM is | A working environment: Codespaces, or Verilator ≥ 5.050 + `z3` |
| 2 | **U1** · The VTALU spec · The verification plan | The VTALU plan on the template in [`plan-de-verificacion.md`](../plan-de-verificacion.md) *(in Spanish)* |
| 3 | **U2** · The conventional testbench · Functional coverage | [`d1`](../../code/ejercicios/d1/) — a new operation end to end |
| 4 | **U2** · Interfaces and BFM · `clocking block` | [`d1b`](../../code/ejercicios/d1b/) — the bug you can only see in the `.vcd` |
| 5 | **U3** · Classes and extensions · Polymorphism | [`d2`](../../code/ejercicios/d2/) — extending without copying the whole class |
| 6 | **U3** · Static variables and methods · Parameterized classes | `d2` (wrap-up) |
| 7 | **U3** · The factory pattern · A testbench without a single module | Review: questions **7–14** of the bank, in class |
| 8 | **Midterm 1** (1 h) + **U4** · Tests | — |
| 9 | **U4** · Components and phases · The env | [`d3`](../../code/ejercicios/d3/) — a factory override without touching the `env` |
| 10 | **U4** · Reporting · **U5** · One producer, many listeners | [`d4`](../../code/ejercicios/d4/) — one more subscriber |
| 11 | **U5** · A single place that watches the wire · Who waits for whom | [`d5`](../../code/ejercicios/d5/) — the scoreboard shouts and the DUT is healthy |
| 12 | **U6** · Copying an object that holds another · Transactions | [`d5b`](../../code/ejercicios/d5b/) — measure your `dist` |
| 13 | **U6** · Constrained random + **Midterm 2** (1 h) | [`d6-bins`](../../code/ejercicios/d6-bins/) — closing a directed bin |
| 14 | **U7** · Agents · Sequences — and *Callbacks* and *Virtual sequences* if they fit, which are the first two on the list of cuts | [`d6-agents`](../../code/ejercicios/d6-agents/) · [`d6-sequences`](../../code/ejercicios/d6-sequences/) · [`d6-semillas`](../../code/ejercicios/d6-semillas/) with `make regresion` |
| 15 | **U8** · Assertions (SVA) | [`d7-sva`](../../code/ejercicios/d7-sva/) · **capstone kick-off** |
| — | *(exam period)* | **Capstone**: [`d7-final`](../../code/ejercicios/d7-final/) |
| + | **Day 8** *(optional)* · **U9** · RAL · DPI · the second capstone — outside the 15 weeks | [`d8-ral`](../../code/ejercicios/d8-ral/) — the register map · [`d8-fifo`](../../code/ejercicios/d8-fifo/) — the second capstone |

**Day 8** is the row left over on purpose. It does not fit in a 15-week term and
the course does not need it to close: it is there for the group that arrives
with time to spare, for a graduate seminar, or as an optional graded assignment.
All three pieces depend on the capstone being done, so they only work
**afterwards**:

- **U9 · RAL** — 45 min of theory and a one-hour lab. It reuses the DUT and the
  testbench of the capstone. The argument to make sure lands is the one in the
  last section: RAL models addressable storage, not behaviour.
- **The reference model in C, through DPI** — 30 min, with no lab of its own:
  the `code/u8/dpi/` example runs and reads. It is the industry technique for a
  DUT with serious arithmetic, and no course tied to a licence can show it
  running.
- **The second capstone** ([`d8-fifo`](../../code/ejercicios/d8-fifo/)) — two
  hours. It is the best optional graded assignment in the repository, and for a
  concrete reason: the bug to be caught is in a **flag**, not in the data, so a
  scoreboard that only compares what comes out passes green. It separates
  whoever understood from whoever copied the pattern of the first capstone.

The four **appendices** of day 7 —from the VTALU to a real bus, the debug
toolbox, the twenty silent traps and the glossary— take no class time: they are
given as **reading**, because the course has a book. `en/libro/day7.html` is the
same material to read straight through, with the instructor's notes inside the
text. The debug and traps appendices are read before the capstone; you can tell
which group did it.

## What can be skipped

In this order. Each cut is honest: it says what is lost, it does not promise it
is free.

| What goes | What you gain | What it costs |
|---|--:|---|
| **Virtual sequences** (U7) | 30 min | Nothing in day 6 depends on it. It is the section the student will need the day they have two agents, not before |
| **Callbacks** (U7) | 15 min | The third hook of unit 1 ends up promised and not delivered. If it goes, take it out of the slide *Run more tests writing less code* too |
| **Parameterized classes** (U3) | 30 min | It can be told in 5 min as "this is what `uvm_driver #(T)` does" and move on. It is the section furthest from UVM in the whole course |
| **`put`/`get` ports** (U5) | 30 min | Analysis ports —the ones UVM uses all the time— are untouched. `put`/`get` shows up in real TLM, not in a typical testbench |
| **The review in class** (the seven quizzes) | 1 h 30 total | They become homework with the [exam bank](exam-bank.md). But you lose the best moment of the course for spotting who did not get it, and that gets paid for in the midterm |

What it is **not** wise to cut, however tempting:

- **The verification plan** (U1). It is half an hour and it is what turns the
  day 6 covergroup into something you derive instead of invent. Without it,
  stage 4 of the capstone has nowhere to come from.
- **Reporting** (U4). It looks like an accessory and it is 47 % of the real
  work. The whole course aims at that figure from the very first slide.
- **The capstone**. It is the difference between *"I took the course"* and *"I
  know how to do it"*. If there is no time for the whole capstone, ask for
  **stage 1 only** —the monitor over the passive APB slave—: it takes half an
  hour and it already leaves something to hand in.

## The two midterms

The [exam bank](exam-bank.md) has the 45 questions without the answer marked,
and the key at the end with the reasoning for each one. They come from the same
slides as the deck, so there are no two versions of a question that can drift
apart.

| | Covers | Questions from the bank | Suggested practical part |
|---|---|:--:|---|
| **Midterm 1** | U1–U3: why you verify, the testbench without UVM, the OOP UVM takes for granted | **1–14** | Extend a class from the course and do a `set_type_override` — the statement of [`d2`](../../code/ejercicios/d2/) or [`d3`](../../code/ejercicios/d3/) with another operation |
| **Midterm 2** | U4–U6: phases, env, reporting, how the components talk, transactions and constrained random | **15–30** | Hang a subscriber off the analysis port and count something — [`d4`](../../code/ejercicios/d4/) with another metric |
| **Final / capstone** | U7–U8 and everything before | **31–45** | The capstone, below |

The 45 are enough for two midterms and a retake without repeating, if you take
10 per exam. To take two rows on the same topic —one in the midterm and another
in the retake— the *Topic* column of the key groups them.

**What to look at when marking the multiple choice.** The wrong options in this
bank are not filler: nearly all of them are the mistake people actually make. A
student who marks *"the covergroup reads 0 % because the bins are wrong"*
instead of *"nobody calls `sample()`"* did not get a detail wrong, they have the
wrong mental model — and that mistake is going to come back in the capstone.

## Marking the capstone

The capstone ([`d7-final`](../../code/ejercicios/d7-final/)) is a four-register
**APB3** slave, its specification, and a blank sheet. There is no file with a
hole in it: the testbench is written whole.

**The marker goes in stages and each one prints its `STAGE N OK`**, so the grade
comes out of running `bash run.sh` and reading how far it got:

| Stage | What the student proved | Suggested weight |
|:--:|---|--:|
| **1** · Monitor | A passive agent that reconstructs transfers by watching the bus, with no driver | 20 % |
| **2** · Driver | The protocol inside the interface, with its *wait state*, and a directed sequence | 25 % |
| **3** · Scoreboard | The DUT modelled in software. It is run twice: against the healthy DUT it has to stay quiet, and with `+BUG=1` it has to **shout** | 30 % |
| **4** · Coverage | The covergroup comes out of the seven rows of the verification plan in the spec: > 20 points, 90 % covered | 15 % |
| — | **The verification plan handed in**, with its five columns | 10 % |

Stage 3 is the one that sorts people out. A scoreboard that never saw an error
is not tested: `+BUG=1` removes the `CTRL.EN` gate from the DUT, and a model
that did not model `EN` passes both runs. The marker catches it — it is a
mutation test, and it is exactly what a real regression would do.

The four traps in the spec are there on purpose, and all four are **spec read
wrong**, not UVM: the wait state on the read, the `CLR` that is never read as 1,
the read-only register that gets written without raising an error, and the
accumulator that only runs with `EN=1`. If a whole group falls into the same
one, they almost certainly skipped *The small print* in `spec.md`.

**Oral defence, three questions that pay off:** why the monitor watches the wire
and not what the driver sent; which bin was left open and why; and what would
happen if `PREADY` took two cycles instead of one.

## The self-assessment rubric

Day 7 closes with **15 statements** of the kind *"I can explain why a sequence
does not show up in `print_topology()`"*, each one with the section where the
answer is. It is for the student, not for the teacher: it works as a study guide
before the final, and as an honest diagnosis for whoever takes the course alone.

It also works well as the **first slide of the office-hours class**: project it,
and the three that get the most hands up are the ones to go over again.

## What marks itself

```sh
make ejercicios     # runs the 15 SOLUTIONS: checks that they are still solvable
make regresion      # N seeds + coverage merge + HTML report of open bins
npm run check       # the exam bank and the deck, in sync with slides/
```

`make ejercicios` does **not** check that a student solved anything: it checks
that the fifteen are still solvable when the course code is touched. It is the
net to run after adapting an exercise.

`make regresion` is the [`d6-semillas`](../../code/ejercicios/d6-semillas/)
exercise turned into a tool: it runs the same test with N seeds, merges the
coverage and leaves in `dist/regresion/regresion.html` the list of **open
bins**, which is the only useful question after a regression. It works as a
classroom demo —the students see that the tenth seed adds nothing— and as the
marker for a coverage-closure assignment.

## The lab

| | What for | If it is missing |
|---|---|---|
| **Verilator ≥ 5.050** | The simulator. Covergroups landed there | there is no functional coverage, which is half the course |
| **`z3`** | `randomize()` with constraints | it compiles, it runs, and `randomize()` returns **0 silently** from day 5 on |
| **`ccache`** | optional | the second build of a UVM example takes 1 min 30 instead of 15 s |

**The recommendation for a university subject is Codespaces**: `.devcontainer/`
ships Verilator, UVM, `z3` and `ccache` inside, a free account gives 60
core-hours a month —more than enough— and it avoids the half afternoon per
student that installing Verilator on macOS or Windows costs. The alternative
without an account is the Docker image; see [`docker.md`](../docker.md)
*(in Spanish)*.

What works and what does not, with the coverage number of each example, is
measured in [`verilator.md`](../verilator.md) *(in Spanish)*. The two sections
on silent failures —`z3` and assertions without `--assert`— are worth reading
**before** the first lab class: they are the two ways this environment has of
lying without raising an error.

## If you find a problem

An example that does not run, an explanation that does not land or a badly
worded question in the bank are **issues of the course**, not problems of
whoever teaches it:
[Discussions](https://github.com/leandrotozzi/verifythis/discussions), with one
category per day. If you already fixed it, better still:
[`CONTRIBUTING.md`](../../CONTRIBUTING.md) *(in Spanish)*.
