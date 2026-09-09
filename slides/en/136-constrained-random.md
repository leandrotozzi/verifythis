<!-- es-sha: 06ec3ce2e16d -->
## Constrained random

#### *The other half of the pincer*

- The functional coverage of the conventional testbench tells you **what is
  missing**. It does not tell you how to get there: that is the stimulus
- Writing a directed test per bin does not scale — there are 76 of them in the
  VTALU, and a real chip has thousands
- The industry recipe is the other way round: **random for the bulk, directed for
  the holes**. And the random has to be *legal*, or the DUT complains about things
  that are never going to happen in silicon
- *Constrained random* is writing the rules of the stimulus **once, in the
  transaction**, and letting the solver build the cases

Note:
It is the half of the pair that was missing: up to here the course measured
coverage and built the transactions, but the stimulus still came out of a
`get_op()` with a hand-written `case`.
The sentence that orders the section: **a constraint does not pick a value, it
describes the set of legal values.** The one that picks is the solver, and it
picks differently from what you expect more often than you would like. The whole
section is about measuring that instead of assuming it.

---

## Constrained random

#### *`rand` and `randomize()`: what you have already seen*

```systemverilog
class command_transaction extends uvm_sequence_item;
   rand byte unsigned A;      // rand  -> it enters the draw
   rand byte unsigned B;
   rand operation_t   op;     // an enum randomizes over its values

   constraint data { ... }    // the rules, in a block of their own
endclass
```

- `randomize()` comes from SystemVerilog, not from UVM: **every** class has it
- It picks values for the `rand` fields that **satisfy every active constraint at
  once**
- A `constraint` **is not sequential code**: it does not run from top to bottom, it
  has no order. It is a set of relations the solver satisfies together
- That is why two constraints that contradict each other do not give a compilation
  error: they give a `randomize()` that returns 0

Note:
The bullet to say slowly is the third one, because it is the wrong mental model
everybody brings along: a `constraint` **does not run**. It is not a long `if`, it
does not go from top to bottom, and the order they are written in makes no
difference. It is a system of equations, and `randomize()` hands it to a solver
—in this course, z3— so that it returns a random solution out of all the ones that
satisfy it.
From there comes the consequence of the last bullet, and it is the most expensive
trap of the section: two incompatible constraints compile perfectly. The error
shows up at simulation time, `randomize()` returns 0, and **if nobody checks the
return value the class is left with the values it had**. The testbench goes on
running and sends garbage.
The rule to take away from here, and one the course keeps everywhere in `code/`: a
`randomize()` always goes inside an `if` that checks the return value. Never on its own.

---

## Constrained random

#### *`dist`: `:=` is not the same as `:/`*

```systemverilog
A dist {8'h00 := 1, [8'h01 : 8'hFE] := 1, 8'hFF := 1};   // the weight goes to EACH value
A dist {8'h00 :/ 1, [8'h01 : 8'hFE] :/ 2, 8'hFF :/ 1};   // the weight gets SPLIT
```

- `dist` sets **weights**: it does not change which values are legal, it changes
  how often they come up
- With `:=` the weight is applied **to each value of the range**: the middle range
  weighs 254 and the edges 1 each. `A=00` comes up **1 time in 256**
- With `:/` the weight belongs to **the whole range**: 1 – 2 – 1 gives 25 % on
  `00`, 50 % in the middle, 25 % on `FF`. Which is exactly the bias the
  `get_data()` of the conventional testbench did by hand
- Both lines compile, both run, and **one of the two never fills the edge bins**

Note:
The arithmetic has to be done on the board, because read out loud it does not sink
in: with `:=` the weights are 1, 1 and 1, but the middle one is applied to **each
one** of its 254 values. A total of 256 equal parts, and `A=00` comes up one time
in 256. With `:/` the parts are three —1, 2 and 1— and `A=00` comes up one time in
four. Sixty-four times more often, for two characters.
And now the part that makes it dangerous: **both versions work**. Neither gives a
warning, neither fails, the testbench runs the thousand transactions just the
same. The only thing that changes is that with `:=` the `a_00` bin of the
covergroup takes an eternity to fill, and whoever looks at the report concludes
that a test is missing.
It is exactly the kind of bug the course calls a silent trap, and that is why the
next slide does not explain: it **measures**. The practical rule to hand down: if
you write a `dist`, run a histogram before believing it.

---

## Constrained random

#### *Do not assume it: measure it*

{{code:code/u6/transactions/constraints/01_dist.sv|lines=8-19}}

```sh
$ cd code/u6/transactions/constraints && bash run.sh
400 randomizations of each version
  :=   A=00   0.2%   A=FF   0.2%   the weight goes to each value
  :/   A=00  23.2%   A=FF  27.0%   the weight gets split
```

Note:
This experiment came out of a bug in this very course: `command_transaction` had
the `dist` written with `:=`, which means the bias to the corner cases the
transactions claimed to have **did not exist**. The distribution was practically
uniform and nobody found out, because the testbench passed just the same.
That is the underlying point of the section, and it is worth saying it that
bluntly: a badly written constraint **does not fail, it lies**. There is no
warning, there is no compilation error, there is no test in red. The only thing
that gives it away is the coverage that does not go up — and that is only noticed
weeks later.
A practical rule to take home: every time you write a `dist`, run a few thousand
randomizations and print the histogram **once**. It costs ten minutes and it is
the difference between believing and knowing.

---

## Constrained random

#### *`inside` and `randomize() with {}`*

{{code:code/u6/transactions/constraints/02_with.sv|lines=16-29}}

{{code:code/u6/transactions/constraints/02_with.sv|from=c.data.constraint_mode(0);|to=with with: 1 try}}

- `inside {a, b, c}` is the set of legal values: without it, the random also asks
  for `no_op` and `rst_op`, which compute nothing
- `randomize() with { ... }` adds constraints **for that call only**: the directed
  case gets asked for at the point of use, without touching the class and without
  writing a new tester. It is the tool of *coverage closure*

Note:
The number from the run is the whole argument of the section: 400 random attempts
fill `mul_max` a handful of times —6 with the default seed, between 2 and 8
depending on which one you use— **because the `dist` biases towards the edges**.
The arithmetic is worth doing out loud: `op` comes out uniform among four and each
leg lands on `FF` one time in four, that is 1/4 × 1/4 × 1/4 = **1 in 64**, which
over 400 attempts is six and a bit. With the badly written `dist` of the previous
slide, the probability of both legs landing on `FF` is 1/65536 per operation: you
never touch it.
The mental sequence is always the same: I run random, I look at which bin was left
empty, I write a three-line `with {}`, I run again. Never "I write 76 tests".
The Verilator limitation that shows up in the output is there on purpose, and it
is worth stating it properly because it is not a matter of "it works or it does
not". Verilator resolves the `dist` **by picking a concrete value first** and only
then checks the rest: if the one drawn does not satisfy the `with`, it returns 0
instead of looking for another. The success rate is therefore the probability of
the bin. Measured: `with {A == 8'hFF}` resolves 25 % of the time —the weight of
that bin—, `with {A inside {[1:10]}}` 2 %, and a field with no `dist` 100 %.
Why it matters more than it looks: the symptom is **an intermittent directed
case**, which works when you try it and fails in the overnight regression. The
numbers are in `code/verilator/repro-dist-with.sv`, and the way around it —turning
the constraint off— is the same `constraint_mode()` you see two slides further on.

---

## Constrained random

#### *The order of resolution biases without warning*

```systemverilog
rand bit           es_reset;
rand byte unsigned A;
constraint c {es_reset -> A == 8'h00;}   // "if I ask for a reset, the operands at zero"
```

- It looks harmless. **It is not**: the solver picks uniformly among the
  *solutions*, not among the values of each field
- With `es_reset = 1` there is **one** solution (`A = 00`). With `es_reset = 0`
  there are **256**. Total: 257, and only one of them has the reset
- Which means: you asked for a reset half the time and you are going to see it **1
  time in 257**. The *"any operation after a reset"* bin of the plan of the
  conventional testbench does not get filled, and the report does not tell you why
- The answer from the language is `solve es_reset before A`: pick the control field
  first

Note:
The sentence that dismantles the intuition is the one in the first bullet, and it
is worth repeating it word for word: **the solver picks uniformly among the
solutions, not among the values of each field**. Nobody wrote that `es_reset` was
going to come out 1 half the time; that came from assuming each field gets drawn
separately, and it does not.
It is worth counting the 257 solutions out loud, because the number convinces more
than the argument: `es_reset=1` forces `A=00`, that is to say a single
combination; `es_reset=0` leaves `A` free, that is to say 256. The draw is over the
257, and the reset takes one of them.
The connection with the verification plan is what makes this slide worth it: the
row *"any operation after a reset"* does not get filled, the coverage stays pinned
down, and the report does not say **why**. A student without this slide adds
random tests for an afternoon.
And the warning about the cure, so that it does not get overused: `solve ... before`
does not change which solutions are legal, only the order in which the solver
picks. It is a distribution knob, not a correctness one — and it costs solver
time, so it goes where it is needed and not out of habit.

---

## Constrained random

#### *Measured, with the way round that Verilator does honour*

{{code:code/u6/transactions/constraints/03_solve.sv|lines=10-25}}

```sh
2000 randomizations of each version
  as written             es_reset=1 in   0.3%   (1 in 257)
  with dist on es_reset  es_reset=1 in  51.7%
```

- Verilator 5.052 **accepts `solve ... before` and does not honour it**: it leaves
  the field pinned at 0, which is worse than ignoring it. Repro in
  `code/verilator/repro-solve-before.sv`
- The portable way round: ask for the share-out of the control field with a `dist`.
  It says the same thing and it does not depend on the solver getting the order
  right

Note:
It is the second Verilator hole of the course, alongside the transition bins, and
it gets treated the same way: it gets said head on, with a minimal repro and with
a way round that works. The concept belongs to the language, not to the simulator.
What does have to be stressed is the asymmetry: the **biased** constraint gives
0.3 %, which is exactly what the theory predicts — which means the Verilator
solver is fine; what is missing is the ordering directive.
And the general moral, which holds for any tool: if the stimulus has a control
field (a mode, a kind of operation, an "inject an error"), do not trust it to come
out even. Measure it.

---

## Constrained random

#### *When there is no solution*

{{code:code/u6/transactions/constraints/04_falla.sv|lines=8-32}}

```sh
1. randomize() returned 0: the constraints do not close
2. with 'grande' turned off: A=06, and it honours 'chico'
3. with A out of the draw: A=06, the same as before
```

- `constraint_mode(0)` turns **one constraint** off at run time; `rand_mode(0)`
  takes **one field** out of the draw and leaves it with the value it had
- They are for the test that needs to break a rule on purpose — injecting an
  illegal opcode, for instance — without touching the class everybody else uses

Note:
Here the circle closes with the `assert(randomize())` slide: case 1 is precisely
what happens when two constraints contradict each other, and without the `else`
the testbench goes on sending the previous transaction.
`constraint_mode` has a relative worth naming even though we do not use it: `soft`
constraints, which the solver drops on its own when they get in the way instead of
returning 0. They came in with IEEE 1800-2012 and they are the modern way of writing a
default value that a `with {}` can override.

---

## Constrained random

#### *This is how coverage gets closed*

| Step | Tool |
| --- | --- |
| Cover the bulk cheaply | `randomize()` with `dist` and `inside` in the transaction |
| See what was left out | the coverage report — `cov_report` |
| Fill the bin that is missing | `randomize() with { ... }`, three lines, no new classes |
| Break a rule on purpose | `constraint_mode(0)` / `rand_mode(0)` |
| Repeat | another seed, and again |

- That is *coverage closure*, and it is what a verifier spends the day on
- What it is **not**: writing one test per bin. Nor looking at the total
  percentage
- The stimulus still comes out of a `tester` you wrote yourself. In modern UVM
  that is a `uvm_sequence` — and that is day 6

Note:
Close by going back to the conventional testbench: the 86.8 % of `u2/convencional`
comes out of 1000 random operations with the bias to the edges put in by hand. Now
the student knows how to write that same bias in a constraint, measure it, and add
the `with {}` for the cases that are missing.
And leave the day 6 question hanging: if the stimulus is constraints and not code,
what does a `tester` class with a `run_phase` go on existing for? It does not go on
existing. It is called a sequence.

---

## Constrained random

#### *"Another seed, and again": what it moves and what it does not*

```sh
$ SEED=7 bash run.sh    # u6/transactions/constraints, 400 randomizations
    seed: 7
  :/   A=00  25.0%   A=FF  22.0%   # with SEED=8: 20.8% and 27.0%
$ SEED=7 bash run.sh    # u2/convencional, and again with SEED=8
  covergroup : 86.8% (66/76)       # both times. And the merge, the same
```

- `SEED=N` passes `+verilator+seed+N`, and `run_sim` **prints the one it used**: a
  failure that comes up once every ten runs does not get debugged, it gets repeated
- It **does** move the percentages of a `dist` measured with few samples: 400
  randomizations give 25 % or 21 % depending on the draw. It is a sample, not the
  distribution
- It does **not** move the 10 bins that are missing. With 1000 operations the
  random already got as far as it can, and another seed is tossing the coin
  expecting a different result
- That is why *"repeat"* is the **last** row of the previous table and not the
  first: the `with {}` comes first

Note:
This slide exists to defuse a misunderstanding the previous table invites: *"if I
do not close, I run another seed"*. It was measured, and no: `code/u2/convencional`
gives 66 out of 76 with the default seed, with 7 and with 8, and the merge of the
three gives 66. The 10 that are missing are not missing out of luck — they are
missing because they are transition bins Verilator does not measure and crosses the
stimulus does not reach. No seed is going to touch them.
The seed is good for two other things, and both are matters of craft. First:
**reproducing**. An intermittent bug does not get debugged, it gets repeated; and
to repeat it you have to know which seed it came up with, which is exactly why
`run_sim` prints it on every run.
Second: **accumulating**, when the stimulus has not saturated yet. A real
regression is the same test over a hundred seeds overnight, and the coverage gets
merged — `verilator_coverage --write` does in Verilator what the ucdb merge does in
Questa. Here it does not show because the example is small; on a chip it is half
the work.
And the `+verilator+rand+reset+2` that shows up in the documentation is something
else and it is worth not mixing them up: it does not touch `randomize()`, it decides
what the **uninitialized** signals of the DUT start with. With `2` they start at
random instead of at zero, which is the way to discover the register nobody reset
and that in silicon does not start at zero.

---

## Constrained random

#### *Summary of the unit*

- The coverage tells you **what is missing**; constrained random is **how to get
  there**. They are the two halves of the same pincer
- Writing a directed test per bin does not scale: there are **76 bins** in the
  VTALU. The recipe is the other way round — **random for the bulk, directed for
  what is left**
- A `constraint` **is not sequential code**: it does not run from top to bottom. It
  is a system of equations the solver resolves all together
- That is why two constraints that contradict each other **do not give a
  compilation error**: they give a `randomize()` that returns 0
- `dist` sets **weights**, not legality. And `:=` is not `:/`: the first weighs
  **each value** of the range, the second **the whole range**
- `randomize()` returns 0 and carries on. That is why it **always** goes inside an
  `if` with `` `uvm_fatal `` — it is the most expensive silent trap of the course

Note:
The last bullet is the one to leave burned in and the one that connects with the
appendix of the traps. An unchecked `randomize()` does not break: it leaves the
fields with the previous value and the testbench goes on sending stimulus that is
not the one you think. The coverage is going to tell you three days later.
And the tool notice that is needed from today: without `z3` installed, Verilator
resolves `randomize()` by returning 0 **in silence**. It is in
`docs/verilator.md`, and it is the reason day 5 asks for the solver.
