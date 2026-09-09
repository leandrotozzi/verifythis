<!-- es-sha: 363f4ae0559a -->
## Assertions (SVA)

#### *The hole the scoreboard left*

- The scoreboard of this course checks **the result**: `A op B` against what
  the DUT gave back. A thousand operations, a thousand comparisons, zero errors
- Nobody checks **the protocol**. A DUT that gives back the right `result` but drops
  `done` one cycle early, or raises it on a `no_op`, **passes every test of the
  course**
- The rule of the protocol is written in three places: in prose in the spec,
  inside the BFM, and in the head of whoever wrote it. In **none** of the
  three is it checked
- An **assertion** is that same sentence, in executable form, running on its own the whole
  simulation

Note:
It is worth opening the section with the question and leaving it hanging for half a minute: *which
part of the testbench would notice if the DUT raised `done` two cycles early?*
The honest answer is none, and it comes as a surprise, because by this point the testbench
already has a scoreboard, coverage, two agents and sequences.
The reason is structural, not an oversight: the scoreboard receives *transactions*, which
is precisely what is left **after** erasing the protocol. The monitor erases it
in the analysis ports and it does well: that is what makes the scoreboard not know
that a `clk` exists. The price is that the layer that sees the wires —the interface— is
the only one that can check them, and until today it only moved them.
This is also the answer to *"why is SVA the other half of
verification?"*: it is not another technique for doing the same thing, it is the half this
testbench does not cover.

---

## Assertions (SVA)

#### *Immediate and concurrent: the one you know and the new one*

```sv
// IMMEDIATE: it is a STATEMENT. It runs when the thread goes past it,
// once, and that is all. The one from the transactions is of this family.
assert (cmd.op inside {add_op, and_op, xor_op, mul_op})
   else `uvm_error("SEQ", "invalid operation");

// CONCURRENT -- the new thing. It is a DECLARATION with a clock: it gets
// plugged in when the simulation starts and evaluated on every edge, forever.
a_done : assert property (@(posedge clk) start |=> ##[0:4] done);
```

- The **immediate** one lives inside a `begin/end`, it is procedural, and it only exists
  while the thread is standing there
- The **concurrent** one lives in no thread: it is a declaration, like an
  `always`. It gets written once and checks every edge of the whole simulation
- That is why a concurrent one can describe something that **lasts several cycles**, and an
  immediate one cannot

Note:
The distinction is hard at first and it is worth anchoring it with the RTL analogy:
an immediate one is to an `if` what a concurrent one is to an `always_ff`. The
first executes; the second gets **instantiated**.
The practical consequence is the one that matters: the immediate one can only look at the
present —the value of a variable at that instant—, while the concurrent one
has a time axis of its own and can say *"if this happens, three cycles later
that has to happen"*. No amount of `if` writes that sentence without
inventing state machines by hand.
And the hook back to the transactions: `assert(x.randomize())` is an immediate one, and there
is the silent trap of that section —`assert` is a simulation directive, and
with asserts switched off the argument does not get executed. Here you see why: they are the
same keyword for two different things.

---

## Assertions (SVA)

#### *Anatomy of a property*

```sv
a_done_llega :                      // <- the label: NOT optional
assert property (
   @(posedge clk)                   // <- the clock: when it gets sampled
   disable iff (!reset_n)           // <- when NOT to check
   start && (op_set != no_op)       // <- the antecedent
   |->                              // <- the implication
   ##[1:5] done                     // <- the consequent
) else `uvm_error("SVA", "...");    // <- what to do if it fails
```

- It reads like a sentence: *"on every edge of `clk`, as long as there is no reset, if
  `start` is up with a real operation, then `done` arrives within
  five cycles"*
- The **label** comes out in the error message and in the coverage report. A
  property without a label is an anonymous error at three in the morning
- The seven parts are always the same. The rest of the section is learning what
  can go in each one

Note:
It is worth writing this slide on the blackboard as a template and going back to it every
time a new property comes up: the student who gets lost in SVA almost always
gets lost because they do not tell the antecedent from the consequent.
The label deserves a paragraph of its own. Without it, the simulator invents one
(`__unnamed$$_0`), and that name is the one that is going to show up in the log of the nightly
regression and in the assertion coverage report. It is exactly the same
argument as the `begin : nombre` the course has been using since interfaces and BFM.
The `disable iff` is looked at in detail further on, but it is worth getting ahead of why it is
so high up in the template: it is the part that gets forgotten most and the one that generates the most false
positives.

---

## Assertions (SVA)

#### *`|->` against `|=>`, mistake number one*

```sv
// |->  overlapping: the consequent starts on THE SAME edge
a : assert property (@(posedge clk) start |-> !done);

// |=>  non-overlapping: the consequent starts on the NEXT edge
b : assert property (@(posedge clk) start |=> !done);
```

- `a |=> b` is exactly `a |-> ##1 b`. There is no more mystery than that
- Which one goes in? It depends on whether the response is **combinational** (the same edge) or
  **registered** (the next one). In the VTALU, `done` comes out of an `always_ff`:
  it is always the next one
- Getting it wrong does not have a single symptom: `start |-> done` with a registered
  `done` **fails on every transaction** —it sees the old `done`—, and a property whose
  antecedent never occurs passes vacuously. That is why it always goes with its `cover`

Note:
This is the first question of every SVA interview and it is worth practising it
with the DUT in hand: `done_1c <= start && (op != 3'b000)` is an NBA, so
what gets written on edge *n* is only read on *n+1*. With `|->` the
property would compare `start` against the **old** `done`.
The operational rule, which is more useful than the theory: `|=>` **is** `|-> ##1`, so
the question is not which of the two operators goes in but **how many edges later** the
spec promises it. An `assign` answers on the same edge and a `<=` on the next one, but
that is the easy case: the star property of this very section —`start && op_set !=
no_op |-> ##[1:5] done`— uses `|->` for a `done` that comes out of an `always_ff`,
because the spec promises a window of one to five edges and not a single one.
And the trap to name out loud, without overstating it: getting this wrong sometimes
shouts —`|->` against a registered signal fails on every transaction— and sometimes
stays quiet, when the antecedent you wrote never occurs and the property is vacuously
satisfied. That second case is the one the final report takes as good, and it is the
reason why the `cover property` slide is not an extra: it is the only check of the
check.

---

## Assertions (SVA)

#### *Looking at the past: `$rose`, `$fell`, `$stable`, `$past`*

```sv
$rose(start)      // 0 -> 1 between the previous edge and this one
$fell(done)       // 1 -> 0
$stable(A)        // the value is the same as on the previous edge
$past(result, 3)  // the value it had 3 edges ago
```

- The four of them compare **against the previous sample**, not against the previous
  instant. In SVA time is counted in edges of the property's clock, not in
  nanoseconds
- `$stable` is the one that writes *"it was not touched"*, which is half a library of protocol
  rules
- `$past(x, n)` is a free delay line: it is good for checking a fixed latency
  without writing a state machine

Note:
Careful with `$rose` on a signal that moves **on the same edge** the property
samples: it is not going to see it go up on that edge, it is going to see it go up on the next one.
That is exactly the topic of the slide that follows, and it is worth planting it here.
`$past` with the second argument is the one that gets underestimated the most: checking *"the
result of now corresponds to the operands of four edges ago"* is one
line, and by hand it is a shift register and three bugs.
It is worth saying as well where they can be used, because there is a half-truth going
around: they *can* be called from procedural code —an `always @(posedge clk) if
($rose(req)) …` is legal (1800-2017 §16.9.3) and Verilator 5.052 accepts it—, because
that is where they infer the clock from. What they always need is **a** clock: in an
`initial` with no clock event they mean nothing. And the practical limit of this flow:
`$past` with the explicit clock argument is not supported by Verilator (*Unsupported:
$past expr2 and/or clock arguments*).

---

## Assertions (SVA)

#### *The property that is worth the section*

{{code:code/u8/assertions/vtalu_bfm.sv#stable-operands}}

- It is **the rule of slide 1 of day 1**: while `start` is up, the
  operands are not touched. It sat written in prose for six days
- Eleven lines, and they check every transaction of every test, on both agents, without
  anybody connecting them to anything
- The scoreboard **cannot** write this rule: by the time the transaction reaches
  it, the protocol has already been erased

Note:
This is the moment to go back to the spec slide and read it word for word.
The distance between *"the operands must remain stable while `start`
is active"* and the line of SVA on screen is almost zero — and that is the whole
argument for why assertions get written early and not at the end: the
specification **is already written**, it only has to be translated.
The `$stable(op_set)` at the end is the one that tends to be missing and it is the one that catches the ugliest
bug: changing the operation halfway through a transaction is legal for the compiler,
illegal for the DUT and transparent for the scoreboard.
It is worth showing the `@(negedge clk)` and **not** explaining it yet: leave it as a
curiosity that gets cleared up on the next slide. Somebody is going to ask first.

---

## Assertions (SVA)

#### *⚠ Two clocks: an assertion is worth what its sampling is worth*

{{code:code/u8/assertions/vtalu_bfm.sv#two-clocks}}

| With a single clock | Over 1000 operations |
| --- | --- |
| everything on `posedge` | **145 false positives** on the stability of operands |
| everything on `negedge` | false positives on the `done` properties |
| **stimulus on `negedge`, response on `posedge`** | **0 errors** ✅ |

- The BFM drives on `negedge` and the DUT registers on `posedge`. **There is no
  single edge that makes all four properties correct**
- SVA sampling is the *preponed* region: a signal written **on** the edge
  is not seen on that edge, it is seen on the next one

Note:
This is the most valuable lesson of the section and it is not in the tutorials, so
it is worth telling it with the trace in hand: on two consecutive `no_op`, `start` goes down
at `t=111` and comes back up at `t=120` — **between two `posedge`**. The sampling does not
see it go down. The two transactions read as a single one, with the operands
changing in the middle, and the property screams 145 times about something that never happened.
The short way of saying it: *an assertion does not check what happened, it checks what it
saw*. And what it sees depends on a single character in the `@()`.
It is another **silent trap**, and one of the worst: it compiles, it runs, and it throws 145 errors
at you that do not exist. The beginner's reflex is to loosen the property until it
shuts up —and there they are left without a check. The correct reflex is to look at which edge
the one driving the stimulus writes on.
The underlying industrial way out is the **clocking block**, which declares the sampling
once for the whole interface instead of repeating it property by property. It is in
day 1 —`030-interfaces-bfm.md` and `docs/clocking-blocks.md`— and it is worth naming
again here, because only now is the full problem it solves in view.

---

## Assertions (SVA)

#### *Variable latency, in one line*

{{code:code/u8/assertions/vtalu_bfm.sv#done-arrives}}

- `##[1:5] done` says *"between one and five edges later"*. The VTALU takes **one**
  on `add`/`and`/`xor` and **four** on the multiplication: one property covers
  both
- `##n` is an exact delay, `##[a:b]` a window, `##[1:$]` *"at some
  point"* — which is almost never what you want: a property without an upper bound
  can never fail by timeout
- The antecedent **excludes `no_op`** on purpose: it is the only operation that does not
  answer, and putting it inside would turn the property into a generator of false
  positives

Note:
The upper bound is what separates a useful assertion from a decorative one.
`##[1:$] done` is also true for a DUT that answers next Tuesday: it
compiles, it passes, and it checks nothing. The number that goes there comes out of the specification,
not out of what the DUT does today — and if it is not in the specification, that is
the finding of the section.
The 5 in this example has a deliberate margin over the 4 real edges of the
multiplication. It is worth asking the group whether they would prefer `##[1:4]`, and why. The
honest answer is that it depends on whether the specification says *"four"* or says
*"up to five"*: an assertion is a contract, and tightening it more than the contract
turns it into a source of false positives when somebody changes the pipeline.
The `p_no_op_sin_done` below is the complement and it uses `|=>` precisely because of what
the previous slide said: `done` comes out of an `always_ff`.

---

## Assertions (SVA)

#### *`disable iff` and the reset*

```sv
default disable iff (!reset_n);   // once, for the whole interface

property p;
   @(posedge clk) disable iff (!reset_n)   // or property by property
   start |=> done;
endproperty
```

- During a reset **everything is wrong on purpose**: `done` drops, `start` drops,
  the transactions halfway through get abandoned. Without `disable iff`, every reset
  is a batch of false positives
- `disable iff` **aborts** the evaluations in flight, it does not make them fail. The
  property forgets what it was waiting for and starts from zero
- The `default disable iff` at the top of the interface applies it to all of them: it is one
  line against twenty repetitions

Note:
The second classic mistake, after the `|->`/`|=>`. And the symptom misleads: the
regression fills up with errors **at the beginning of every test**, which is precisely when
one looks least, because "it is still initialising".
It is worth naming the inverse mistake, which is more dangerous: a `disable iff` with the
condition the wrong way round —`disable iff (reset_n)`— switches the property off during
normal operation and leaves it active only during the reset. It always passes, it never checks,
and there is no way of realising it from the log. It is the second silent trap
of the section and it is also headed off with `cover property`.
The difference between *aborting* and *failing* matters when the reset arrives halfway through
a long transaction. In this DUT it is one cycle; on a real bus, with
transactions of dozens, it is the difference between a usable property and one that
has to be switched off.

---

## Assertions (SVA)

#### *Where they live: inside the interface*

- They go **with the signals**, in the `interface`, not in the class testbench. There they
  see `clk`, `start`, `A`, `B` and `done` without anybody passing them along
- They do not have to be connected, nor instantiated, nor built in a `build_phase`.
  They exist because the interface exists
- The `top` of the agents instantiates **two** BFM: the same properties check
  both VTALU, including the one driven by the legacy module nobody wrote
- A **passive agent** gets them thrown in for free: watching an interface is now also
  checking it

Note:
This is the slide that connects the section with the whole architecture of the course. The
interface had been the place where the testbench *moves* wires; from
here on it is also where it *watches over* them, and both for the same reason: it is the
only layer that sees them.
The reuse argument is the one that convinces a team: the properties travel with
the interface. Whoever instantiates this BFM in another project gets the protocol check
already fitted, without reading a line of UVM. It is exactly what does not happen with a
scoreboard, which has to be built, connected and configured.
And the twist from the agents is worth saying slowly: the legacy module
—the "boss's tester", without one line of UVM— is also being checked. Nobody
asked its permission. That is the exercise of the day.
---

## Assertions (SVA)

#### *`bind`: when the interface is not yours*

```systemverilog
// The checker lives outside. The RTL is not touched -- often it cannot be.
module apb_checks (input bit PCLK, PSEL, PENABLE, PREADY);
   a_setup : assert property (@(posedge PCLK) PSEL && !PENABLE |=> PENABLE);
   c_setup : cover  property (@(posedge PCLK) PSEL && !PENABLE);
endmodule

// And in the top, one line per module you want to watch over:
bind apb_regs apb_checks chk (.*);
```

- The previous slide holds when the interface **is yours**. Somebody else's RTL, the
  bought IP and the legacy module do not get edited
- `bind` puts an instance **inside** another module from the outside: the checker
  sees the DUT's internal signals as if it had been written there
- The `.*` connects by name. One `bind` covers **every** instance of
  that module — or `bind top.dut ...` for a single one
- You can also bind to an `interface`, and Verilator supports both forms

Note:
This is the interview question that follows the previous slide, and it is worth
putting it like this: *"very nice to put the properties in the interface — and when the
interface is not yours?"*. The answer is `bind`, and it is the way
assertions are used in the industry: one checker file per block, all
bound from the top, and the RTL without a line of verification inside.
The underlying reason is not aesthetic: in a synthesis flow the RTL that is handed over
is the one that gets synthesized, and putting `assert property` inside it forces everybody
to carry the verification along. With `bind`, whoever synthesizes does not compile
the checker file and that is that.
The concrete advantage, and the one that makes it worth it: the bound checker sees the
DUT's **internal signals** — the FSM state, the wait state counter —,
which is exactly what the interface does not see. That is where assertions stop
checking the protocol and start checking the implementation.
And the warning: a badly written `bind` does not fail, connects nothing and the property is
left not running. As always, the antidote is the `cover property` — if the cover
is at zero, the `bind` did not arrive.


---

## Assertions (SVA)

#### *The integration with UVM: the `else` that makes it count*

```sv
// The SystemVerilog default: it KILLS the simulation on the first failure
a : assert property (p);

// What you want in UVM: the failure counts and the simulation goes on
a : assert property (p)
    else `uvm_error("SVA", $sformatf("%m: operand changed"));
```

- Without an `else`, the default action of an assertion that fails is `$error` —and in
  several simulators, `$stop`. The simulation gets cut off and the *Report Summary*
  **does not get printed**
- With an `else` that calls `` `uvm_error ``, the failure comes in through the same channel
  as everything else: it counts in the summary, it respects `+UVM_MAX_QUIT_COUNT`, and the
  `run.sh` detects it without changing a line
- The `%m` of the message prints **which instance** of the interface failed:
  `top.clase_bfm` or `top.modulo_bfm`

Note:
It is the bridge between the two halves of the course and it has to be made explicit: the
assertion is not a world apart with its own report. It is one more `uvm_error`, and
that is why `uvm_summary_ok` of `common.sh` detects it without anything having had to be
touched.
The reason the default is no good is practical: a nightly regression that
gets cut off at the first failure reports **one** failure. The same run with
`uvm_error` reports all 154, and that is the difference between *"something is wrong"* and
*"it is wrong on every multiplication"*.
The `%m` looks like a detail and it is not: with two instances of the same interface,
a message without `%m` does not say which of the two ALUs broke. It is the same problem
`get_full_name()` solved in reporting, with the tool of the language
instead of the one of the library.

---

## Assertions (SVA)

#### *Every assertion goes with its `cover property`*

{{code:code/u8/assertions/vtalu_bfm.sv#the-covers}}

{{code:code/u8/assertions/cover.txt}}

- A property whose **antecedent never occurs** passes. Without assertion
  coverage, a switched-off check looks exactly like a green check
- `c_mult_3ciclos` stays at **zero forever**: the chain of the multiplier
  is `done3 → done2 → done1 → done_mult`, that is **four** edges, not three. The
  cover at 0 gives away that the mental model of the latency was wrong
- In Verilator the `cover property` land in the **same `coverage.dat`** as the
  covergroups of the conventional testbench: code, functional and assertion coverage, one
  single report

Note:
This slide closes the circle the conventional testbench opened and it is worth saying so: the
question *"how do I know I measured?"* had three answers in the course, and this is the
third one. Functional coverage says what stimulus was generated; assertion
coverage says which **checks actually got evaluated**.
The case of `c_mult_3ciclos` is a pedagogical gift and it came out of writing the
section, not out of inventing it: the intuitive count was three —the module is called
`vtalu_mult`— and the hardware takes four, because the `done` travels through a pipeline
of its own. The property with `##3` would have passed just the same if it had been a badly
written `assert`, and the `cover` at zero is the only thing that gives it away.
The rule to take away: for every `assert property` you write, write the
`cover property` of the antecedent. It is two lines and it is the difference between a
testbench that checks and one that says it checks.

---

## Assertions (SVA)

#### *Assertion or scoreboard: the same rule, two places*

| | Assertion | Scoreboard |
| --- | --- | --- |
| What it checks | the **protocol**: who moves, and when | the **transformation**: `A op B` |
| Where it lives | in the `interface`, with the wires | in the testbench, with the transactions |
| When it screams | on the exact edge on which it breaks | when the result arrives |
| What it needs | nothing: it plugs itself in | monitor, analysis port, `connect_phase` |

- Short rule: **protocol → assertion. Data → scoreboard.** Writing a
  protocol check in the scoreboard is rebuilding the time the monitor
  has just taken care of erasing
- And the other way round: writing the reference model of a multiplier in SVA is
  possible and it is a bad idea

Note:
The question that always comes up: *why not check everything in a single place?* The
answer is that the two layers see different things and neither can see the other's
without undoing the monitor's work.
The advantage of the *"it screams on the exact edge"* is the one that saves the most time in
real life, and it is worth putting in numbers: a scoreboard mismatch gives you a
wrong result and you have to track backwards until you find the cycle
where it started. An assertion gives you the cycle. On a bus with overlapping
transactions, that is the difference between half an hour and two days.
The other half of the rule matters too: SVA does not replace the scoreboard. Nobody
wants to read a reference model written in properties, and whoever tried it tells it
as an anecdote.

---

## Assertions (SVA)

#### *The example of the section: the bug the scoreboard does not see*

{{code:code/u8/assertions/vtalu_bfm.sv#the-planted-bug}}

{{code:code/u8/assertions/sva.txt}}

- `+BUG=1` changes `B` **halfway through the multiplication**. The multiplier has already
  latched the operands on the first edge: **the result comes out right all the same**
- The scoreboard compares 1000 operations and does not find a single difference: in the
  summary there is **not one `[SELF CHECKER]`**. It is doing its job properly — this bug is
  not a data bug
- The assertion catches it 154 times, on the exact edge. It is the same example as reporting, turned inside out: over there the scoreboard was broken to teach reporting;
  here the protocol gets broken to show who sees it

Note:
Run both runs live if there is time: `bash code/u8/assertions/run.sh` does the
clean one and the buggy one, one after the other, and the comparison of the two *Report
Summary* is the slide.
It is worth pointing out why the bug is invisible, because it is not obvious: the pipeline
does `a_int <= A` on the first edge and `mult1 <= a_int * b_int` on the second.
Everything that happens to `A` and `B` after the first edge gets discarded. A
designer would say the DUT is *robust*; a verifier would say the testbench
is lying — the stimulus violated the contract and nobody found out.
And the punchline: this bug is not hypothetical. It is exactly what the legacy
module of the exercise does, and it is exactly the kind of thing that survives for years in a
block that "works".

---

## Assertions (SVA)

#### *The traps of this section*

| The symptom | The cause | How to head it off |
| --- | --- | --- |
| The property **always passes** | the antecedent never occurs | one `cover property` per assertion |
| **False positives** on every transaction | you sample it with the edge it is written on | stimulus and response go on different edges |
| False positives **at the start** of every test | the `disable iff (!reset)` is missing | `default disable iff` once, at the top |
| The log says **PASS** and the properties did not run | `--assert` is missing at compile time | the `cover` at 0 is the one that warns you |

- The four share the shape of the appendix: **they compile, they run, and they lie**
- The fourth is the cheapest to commit and the most expensive: without `--assert`, Verilator
  compiles the properties and does not evaluate them. All green, zero checking

Note:
The fourth row deserves a minute because it is specific to the flow of this course and
comes as a surprise: `--assert` is not a "more warnings" flag, it is the switch that
turns a declaration into a check. Without it, the whole block of the interface
is expensive documentation.
And the antidote is the same for all four, which is the elegant part: the `cover
property`. If the cover is at zero, either the property does not run, or its antecedent does not
occur. In both cases you have to go and look, and in both cases the `assert` on its own
would have said that everything is fine.
These four are added to the appendix of the silent traps, which from this
section on are twenty.

---

## Assertions (SVA)

#### *Summary of the unit*

- A **concurrent assertion** is a declaration with a clock: it gets written once
  and checks every edge of the simulation, on its own
- The anatomy never changes: `label : assert property (@(clock) disable iff
  (reset) antecedent |-> consequent) else action;`
- `|->` is the same edge and `|=>` **is** `|-> ##1`. The question is not which of the
  two, it is how many edges later the spec promises it
- The properties live **in the `interface`**, with the signals. They do not get connected, they do not
  get built, and they travel with it
- In UVM the action is `` `uvm_error ``, so the failure **counts** in the
  *Report Summary* instead of killing the simulation
- **Every assertion goes with its `cover property`**: it is the only check of the check
- And the one that takes the section: **an assertion is worth what its sampling is worth**.
  The stimulus gets sampled where the stimulus gets written

Note:
If the group takes away a single sentence, let it be the last one. Everything else in this
section is syntax and can be looked up; the sampling is judgement, and it is what separates a
property that checks from one that makes noise or from one that stays quiet.
The second one to take away is the one about the `cover property`, for a cultural reason: it is
the only defence against the testbench that feels safe. A team with
three hundred assertions and no assertion coverage does not know how many it is
running.
And it is worth closing with the location on the map: this is the half that was missing. The
scoreboard checks what the DUT computes; the assertions, how you talk to it. A
serious verification plan has both columns.

---

## Assertions (SVA)

#### *What this section does differently*

- **The *UVM Primer* has no SVA.** It teaches the class testbench
  end to end and leaves the assertions out: they belong to the other half of
  SystemVerilog
- This section exists because the question comes anyway —in the interview, and in the
  first real block one gets to verify
- The two clocks, the table of the 145 false positives and the `cover property` that
  never gets covered **did not come out of a tutorial**: they came out of writing this
  section on the VTALU of the course and looking at why it did not add up
- Everything here runs on Verilator, without licences, with the same `run.sh` as the
  other thirty-seven examples

Note:
It is worth being explicit with the group about where each thing comes from, because it is part of
what the course teaches: the difference between reading about SVA and writing SVA is
exactly the two-clocks slide. No tutorial has it because the
tutorials use a DUT where stimulus and response share an edge.
It is also the answer to *"why one more UVM course?"*. This one runs. And when
something does not add up, the section tells why it did not add up instead of changing the example.
What is left out and is worth naming so nobody discovers it late:
formal assertions, `expect`, and the prefabricated bus properties that come with
commercial VIP. With what is in this section they can be read without help.
