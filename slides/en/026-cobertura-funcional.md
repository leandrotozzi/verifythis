<!-- es-sha: 88519380b99e -->
## Functional coverage

#### *When are you done verifying?*

- *Code coverage* —lines, branches, toggle— the simulator gives you for free.
  It says which RTL got **executed**
- *Functional coverage* you write yourself. It says which **scenarios of the spec**
  went through the DUT
- They are not the same thing, and the first one misleads: a test that always sends `add_op`
  with `A=B=8'h01` executes almost every line of the adder and verified nothing
- Functional coverage is the *contract* between the spec and the testbench: if a
  case of the spec has no bin, nobody is going to find out it is missing

Note:
The question on the slide is the one a verifier gets asked in the
tape-out meeting, and it is not answered with "I ran a lot of tests".
If somebody asks why code coverage is not enough: because it measures the
DUT, not the spec. A DUT that is missing a whole feature can give 100 % of
lines — the lines nobody wrote do not show up in the report.

---

## Functional coverage

#### *From the verification plan to the covergroup*

The six points of the plan from the previous section, translated:

| From the plan | How it gets measured |
| --- | --- |
| Every operation | `coverpoint op_set` with one bin per operation |
| Corner cases: inputs at 0 and at 1 | `cross` of A, B and the operation |
| Every op after a reset | transition bin `rst_op => op` |
| Mult after single cycle and the other way round | transition bin |
| Every operation twice in a row | repetition bin `[* 2]` |
| Subtract too much: `A < B` and `ovf` goes up | `coverpoint borrow` with the `hubo_borrow` bin |

- The six bullets stop being good intentions: each one is a line of
  code, and the simulator tells you which ones have not happened yet

Note:
It is worth going back to the previous slide and reading the plan out loud before
showing this table: the point is that there is not one item of the plan left
untranslated.
The order matters — the plan first, the covergroup after. The other way round you end up
measuring what the testbench does, not what the spec asks for.

---

## Functional coverage

#### *Anatomy: it is three steps, not one*

```systemverilog
covergroup op_cov;                     // 1. WHAT gets measured
   coverpoint op_set;
endgroup

op_cov oc;                             // 2. it gets INSTANTIATED: it is a type, like a class
initial oc = new();

always @(posedge clk) oc.sample();     // 3. WHEN it gets counted
```

- A `covergroup` is a **type**: declaring it measures nothing, it has to be `new()`ed
- `sample()` is the one that counts. Without `sample()` the report reads **0 %** and the code
  compiles just the same
- *Where* to sample is a design decision. Here, the edge the **DUT reads on**,
  never the same one the tester writes on; when the TB has monitors it will be
  *"every time the monitor sees a command"*

Note:
Everybody's first-time mistake is declaring the covergroup and forgetting the
`new()` or the `sample()`. There is no warning: the report simply says 0 % and you
spend half an hour looking for the bug in the bins.
The third point is the one that holds for the rest of the course: the moment of the sample
defines what you are measuring. Sampling on the clock counts cycles; sampling on
transactions counts operations. In the analysis ports the `coverage` becomes a
subscriber and samples when a command arrives — which is the right thing.
And the edge is not a whim: sampling on the same `negedge` the tester writes
`op_set` on is a race the LRM does not define —Verilator always resolves it the
same way; another simulator may not—. It is the same rule as the day 7
assertions: you read on the opposite edge to the one that writes.

---

## Functional coverage

#### *bins: the buckets that have to be filled*

```systemverilog
coverpoint op_set;                   // automatic bins: one per value of the enum

coverpoint op_set {
   bins single_cycle[] = {[add_op : xor_op], rst_op, no_op};  // [] -> one per value
   bins multi_cycle    = {mul_op};                            // no [] -> a single one
}
```

- Without `{ }`, SystemVerilog creates one bin per value. That works for an `enum`; for an
  `int` the tool chops the range into **64** buckets —`auto_bin_max`— that
  correspond to no row of the plan
- The brackets `[]` **hand out**: one bucket per value of the range. Without them,
  every value falls into the same bucket
- A coverpoint is covered when **all** of its bins have at least one hit.
  A bin that cannot be filled pins your number down forever

Note:
The brackets are the detail most often copied wrong, and it is worth showing it with
both cases side by side: `bins x[] = {[0:3]}` is **four** buckets, and
`bins x = {[0:3]}` is **a single one** that gets filled by any of the
four values landing. The syntax differs by two characters and the number the tool
reports changes completely.
The practical consequence has to be said loudly because it is a silent trap: a
bin without `[]` over a large range **always gives 100 %**. You covered one value out of
a thousand and the tool tells you it is done. Nobody warns you.
And the last bullet is the warning that orders the next slide: a bin that
cannot be filled is not a tool problem, it is a decision somebody did not write down.
The way to write it down is called `ignore_bins` and it comes in
two slides.

---

## Functional coverage

#### *The VTALU covergroup*

{{code:code/u2/convencional/vtalu_tb.sv|lines=44-66}}

- `single_cycle[]` generates six bins —one per operation—, `multi_cycle` a single one
- What is inside `` `ifndef VERILATOR `` are the transition bins: two
  slides further on

Note:
This is the first real covergroup of the course, and it is worth reading it top to
bottom answering the three questions of the previous slide: **what** gets measured (the
coverpoints), **into which buckets** (the bins) and **when** it gets counted (the
`sample()`, which is further down in the same file).
That `multi_cycle` is a single bin and `single_cycle[]` is six is not broken
symmetry: it is the verification plan. The six that are not the multiplication matter
one by one; the multiplication matters as a separate case because it is the only one that takes
more than one cycle. The shape of the covergroup **is** the table of the plan, and that is why the
plan gets written first.
The `` `ifndef VERILATOR `` is worth naming now and not hiding: those bins are
a topic of the course, they are written, and today Verilator does not compile them. It is in
`docs/verilator.md` with the version and the date. A course that covers up what its
tool does not do is a course that lies.

---

## Functional coverage

#### *ignore_bins: saying out loud what does not get covered*

{{code:code/u2/convencional/vtalu_tb.sv|lines=69-84}}

- `all_ops` **ignores** `rst_op` and `no_op`: it makes no sense to ask for "an addition with
  the operands at 0x00" when the operation is a reset
- `a_leg` and `b_leg` bring 256 values down to the three buckets that matter:
  all zeros, the middle, all ones
- An impossible bin you leave in place keeps your coverage pinned below 100 %
  and nobody knows why. `ignore_bins` turns it into a written decision

Note:
There is a relative worth naming: `illegal_bins`. `ignore_bins` takes the bin
out of the count; `illegal_bins` takes it out of the count *and also* reports an error if
it ever happens. It is for the cases the spec forbids — a reserved opcode,
an illegal handshake.
The rule of thumb: if it cannot be covered, `ignore_bins`; if it must not happen,
`illegal_bins`; if it simply has not happened yet, leave it and write the test.

---

## Functional coverage

#### *cross: the combinations, and how not to drown*

```systemverilog
op_00_FF : cross a_leg, b_leg, all_ops;    // 3 x 3 x 5 = 45 bins, almost all meaningless
```

- A `cross` is the **cartesian product** of its coverpoints: it grows fast and
  most of the combinations are in nobody's spec
- `binsof(x) intersect {v}` reads as *"the bins of `x` that contain `v`"*
- They combine with `&&` and `||`, and what is left over gets thrown away with `ignore_bins`
- That way the 45 bins come down to the 11 the plan actually asked for

Note:
The arithmetic in the comment is what has to be done out loud, because the number
is scary and it has to be: three bins of A by three of B by five operations
is **45**, and out of those 45 the plan asked for eleven. The other 34 are not wrong — they are
surplus, and a surplus bin is as expensive as a missing one: it pins your coverage
below 100 % and nobody knows whether it is a real hole.
`binsof(x) intersect {v}` is worth reading in plain words before
writing it, because the syntax does not help: *"the bins of `x` that contain `v`"*.
Then they combine with `&&` and `||` like any condition.
The scale mistake to anticipate: on a real DUT a cross of three
coverpoints with automatic bins is thousands of buckets, and a regression never
fills them. When somebody says "the coverage is not going up", half the time
the problem is an unfiltered cross, not a missing test.

---

## Functional coverage

#### *The VTALU cross*

{{code:code/u2/convencional/vtalu_tb.sv|lines=94-99}}

{{code:code/u2/convencional/vtalu_tb.sv|lines=119-130}}

- `add_00` reads straight through: *an addition where A **or** B is 0x00*
- `mul_max` is the only one with `&&`: it asks for **both** legs at 0xFF: the
  **maximum product**, `FF` × `FF` = `FE01`. It does not overflow — 8 bits by 8 fit in 16
- Verilator 5.052 **ignores** `binsof` / `intersect` (`%Warning-COVERIGN`) and measures
  the whole cross: that is why the number is not a commercial tool's

Note:
Worth reading `add_00` and `mul_max` in plain words, one after the other, because the
difference between `||` and `&&` is the one that gets copied wrong: *"an addition where A **or**
B is 0x00"* against *"a multiplication with A **and** B at 0xFF"*. The first
is two cases, the second is a single one — the **maximum product**, the top corner of
the input space. And here it is worth killing the misunderstanding that comes on its own,
because it is expensive: `FF` × `FF` **does not overflow anything**. It gives `FE01`, which
fits exactly in the 16 bits of `result` —8 bits by 8 never go past 16— and that is why the
DUT forces `ovf` to 0 in every multiplication: `assign ovf = es_mult ? 1'b0 : ovf_1c;`.
The bin is called `mul_max` and not `mul_ovf` for precisely that reason: the case is worth
something for being the maximum of the input space, not for overflowing. The only operation
that overflows is the subtraction, and only when A < B.
The honesty of this slide is part of the course, so it is worth saying and not
rushing past: the 86.8 % the example reports **is not** the number Questa would give.
Verilator ignores the filter and measures the whole cross —the 45, and on top it
adds a value the enum does not have; the "Reading the number" slide says which—, so
the percentage comes out lower and for a reason that is not the testbench's. It is
written, dated and with a version in `docs/verilator.md`.
The useful question for the classroom: does that invalidate the exercise? No. What gets learned
—writing the cross, filtering it, and knowing which bin belongs to which row of the plan—
is identical. The only thing that cannot be done with this tool is signing off on
coverage closure, and that is not the goal of the course.

---

## Functional coverage

#### *Transition bins: when the order matters*

```systemverilog
bins opn_rst[] = ([add_op:mul_op] => rst_op);   // A and then B
bins sngl_mul[] = ([add_op:xor_op], no_op => mul_op);
bins twoops[]  = ([add_op:mul_op] [* 2]);       // twice in a row
bins manymult  = (mul_op [* 3:5]);              // between 3 and 5 times in a row
```

- The last three points of the plan are not values, they are **sequences**: "after
  a reset", "a mult after a single-cycle one"
- Verilator 5.052 still **does not compile them** (Internal Error). In the code
  they are inside `` `ifndef VERILATOR ``: they are part of the topic and read just the same
- Minimal repro in `code/verilator/repro-cg-transition.sv`. The day Verilator
  supports them, the `ifndef` gets deleted and nothing else

Note:
It is the only place in the course where the free tool falls short, and it is worth
saying head on instead of hiding it: the concept belongs to the language, not to the
simulator, and on Questa or VCS these bins run.
There are two more cousins worth naming: `[-> n]` (goto, n times not necessarily
in a row) and `[= n]` (non-consecutive). They are in `coverage.svh` of the analysis ports.

---

## Functional coverage

#### *The knobs: when a bin counts as covered*

```systemverilog
coverpoint op_set {
   option.at_least = 10;                  // a bin only counts at 10 hits
   bins single[] = {[add_op:xor_op]};
}
coverpoint A { option.auto_bin_max = 8; } // 8 automatic buckets, not 64
```

- **`option.at_least`** is the one that matters most: by default it is **1**, so a
  bin that happened **once** already shows up as covered. The corner case that came up once
  in a thousand runs is not verified, and the 100 % says it is
- **`option.auto_bin_max`** bounds the automatic bins. Without `{ }` and without this
  knob, an 8-bit coverpoint does not give 256 buckets: it gives **64**, handed out
  by the tool and not by the spec
- **`option.weight`** changes how much a coverpoint weighs in the total, and
  **`type_option.merge_instances`** adds every instance into a single number
  instead of reporting them separately
- Verilator 5.052 honours `auto_bin_max`, and `at_least` **only written in the
  coverpoint**: in the covergroup it ignores it without warning. It is in `docs/verilator.md`

Note:
This is the slide that puts an asterisk on every percentage of the unit, and
that is why it only arrives now: `at_least = 1` means the tool tells you
**covered** with a single hit. For a bin that represents a value of an enum
that is perfect —either it happened or it did not—. For the bin that represents the maximum
product of the multiplier, one hit is an anecdote, not a verification.
The field rule, and it is worth giving because the question comes on its own: `at_least`
high on the bins that represent a rare case, default on the ones that represent a
value. Raising it for the whole covergroup is not rigour, it is a regression that never
closes and a number nobody looks at.
`auto_bin_max` is the flip side of the bracket trap from three
slides ago. There the problem was a surplus bin; here it is the other way round: if the coverpoint is
an `int` and you write it no bins, the tool invents 64 ranges that do not
correspond to any row of the plan. The number that comes out is real and means
nothing.
And the usual honesty: the four knobs are the LRM's, not Verilator's. What
this tool does with each one is measured, dated and with a repro in
`code/verilator/repro-cg-options.sv`. The `at_least` one is the worst of the four
because it is silent: in the covergroup you write it, it compiles, and it does nothing.

---

## Functional coverage

#### *Reading the number*

```sh
$ make u2/convencional
Coverage Summary:
  covergroup : 86.8% (66/76)
```

- 66 of 76 bins filled, with 1000 random operations. The other rows of the
  summary come out `0/0`: `--coverage-user` leaves code coverage out
- The 10 that are missing are **a single value**: `all_ops.auto_5` and its nine
  crosses. It is `3'b110`, which the enum **does not have** — Verilator hands out
  the automatic bins by the base type, `bit [2:0]`, and not by enum member
- Which means no row of the plan was left uncovered, and on Questa this gives 100 %.
  The number is not the goal: the question that helps is **which** bin is missing,
  and only the per-bin report says that, `obj_dir/top/coverage.dat`
- Run → look at what is missing → write the directed test → run again. That is
  called *coverage closure*, and it is what a verifier spends the day on

Note:
This is where it is worth running it live and opening the `coverage.dat`: the
student has to see that the ten zeros have the same name, and that the name is not
in the `operation_t`. The lesson is to read the report and not the number: the
number says 86.8 % and the report says "nothing is missing, the tool invented a
bucket". On a commercial tool the automatic bin of an enum is one per member
(IEEE 1800, 19.5) and this gives 100 % from the start; it is noted in
`docs/verilator.md`.
And the punchline: the exercise of the day uses precisely `3'b110` for the shift, so
the new operation fills the phantom bucket and the coverage goes from 86.8 % to
100 % — 77 out of 77, with the shift's own bin added. The one who raises it is the
same one who wrote the test, and the checker counts bins and not the percentage,
because we have just seen the percentage cannot read.

---

## Functional coverage

#### *The verification plan, whole and in one table*

| # | Feature | Scenario | Stimulus | Check | Measure |
|:--:| --- | --- | --- | --- | --- |
| 1 | ALU | the six operations | random | scoreboard | `coverpoint op_set` |
| 2 | ALU | operands at `00` and at `FF` | `dist` biased to the edges | scoreboard | cross `op_00_FF` |
| 3 | mult | maximum product: `FF` × `FF` | directed case | scoreboard, 16 bits | bin `mul_max` |
| 4 | reset | operate after a reset | `rst_op` interleaved | scoreboard | bin `rst_op => op` |
| 5 | mult | a mult after a single-cycle one | random | scoreboard | transition bin |
| 6 | ALU | the same operation twice in a row | random | scoreboard | bin `[* 2]` |
| 7 | sub | subtract too much: `A < B`, and `ovf` goes up | random | scoreboard, **two outputs** | bin `hubo_borrow` |
| 8 | sub | `A == B`: the result is 0 and `ovf` does **not** go up | random | scoreboard, two outputs | bin `sub_00`/`sub_FF` |
| 9 | ovf | `ovf` does not go up for any other operation | random | assertion | `c_ovf` |
| 10 | protocol | the operands are not touched with `start` up | random | assertion | `cover property` |
| 11 | protocol | `done` arrives, and before 5 cycles | random | assertion | `cover property` |
| 12 | protocol | `no_op` is the only one that does not answer | random | assertion | `cover property` |

- The three right-hand columns are **the three parts of the testbench** of this
  section. What ties them together is the plan, and until now you had not seen it whole
- The two subtraction rows are the ones that force the scoreboard to look at **two
  outputs**: if it only compares `result`, it passes green with `ovf` stuck at zero
- The **last four** are checked by no scoreboard: they are `ovf` and **protocol**
  rules, and get checked where they happen —the assertions
- The twelve rows are numbered the same as in **`docs/plan-de-verificacion.md`**,
  which also says which file each one lives in and carries the capstone template

Note:
This is the slide that answers *"and what is this for?"* for the rest of day 1, and
it is worth saying head on why it only arrives now: the three right-hand columns
are stimulus, self-checking and coverage — the three parts the previous
unit showed **loose**. The plan is the table that makes them one thing.
The row that gets the most discussion is the maximum-product one, and that is good: `FF` × `FF`
is the only case that does **not** come out of the random in reasonable time, and that is why its
stimulus column says *directed case*. There you see that the plan does not only measure,
it also decides which test has to be written. It is the `d6-bins` exercise, three days
later, with this same row.
The three protocol rows are worth naming and moving on: they are the half the
course does not touch until day 7, and they serve to plant the idea that a scoreboard does not
check everything. A serious verification plan has both columns.
And what the student takes home: `docs/plan-de-verificacion.md` is the same table
as an artifact, with an empty template. The day 7 capstone is handed in with the
plan filled — which is exactly what gets handed in on a project.

---

## Functional coverage

#### *Summary of the unit*

- **Code coverage ≠ functional coverage.** The first one measures which RTL got
  executed; the second, which scenarios of the spec happened
- A `covergroup` is a **type**: it has to be instantiated with `new()` and **somebody
  has to call `sample()`**. Without that the report reads 0 % without a warning
- The **bins** are the buckets. `[]` hands out one per value; without brackets,
  the whole range goes into a single one
- **`ignore_bins` is executable documentation**: it says out loud what does not get
  covered and why. An impossible bin you leave in place pins your number down
- A **`cross`** is the cartesian product and grows extremely fast: without bounding it, the
  coverage never closes
- **`option.at_least` is 1 by default**: a bin that happened once already
  shows up as covered, and a rare case with one hit is not verified
- The number is not the goal. The goal is the **plan**; the coverage only says how much
  of the plan was met

Note:
Closing of the most misunderstood concept of the course. The sentence to take home:
**coverage does not tell you the design is right, it tells you that you tested it**.
A DUT that is missing a whole feature gives 100 % of code coverage and 0 %
of the functional coverage nobody wrote.
And the operational mistake that repeats the most, to leave it burned in: the missing
`sample()`. It compiles, it runs, and the report reads zero.
