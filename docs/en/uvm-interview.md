<!-- es-sha: 3799b0cf7b67 -->
# UVM in the interview

The questions that get asked in a verification interview, with the short answer
and **a link to the section of the course and to the example that runs**. It is
not a summary of the course: it is the order in which things get asked, which is
not the order in which they get taught.

**How to use it.** Read the short answer. If it sounds like something you
already knew, move on. If not, open the link to the book —it is five minutes—
and then run the example, which is the part that makes the answer come out of
your hands instead of your memory. Every example runs on **Verilator and
nothing else**: you do not need a licence to practise for an interview.

> The question they are really asking is almost never the one they say. When
> somebody asks *"what is the factory?"* they are finding out whether you wrote
> a testbench or read a tutorial. That is why every answer here ends in an
> example: saying *"it is for swapping a class without touching the env"* and
> being able to say **where you did it** are two different interviews.

---

## Warm-up: why all of this exists

### 1 · Why UVM and not a SystemVerilog testbench written by hand?

Because the hand-written testbench has the stimulus **inside**: changing test
means changing code and recompiling. UVM turns that around — you compile
**once** and the test is picked when the simulation starts, with
`+UVM_TESTNAME`. A thousand tests at five minutes of build time each are three
and a half days of machine time to run nothing new. That is the whole deal; the
ceremony —factory, phases, a constructor with a fixed signature— is what you pay
for it.

**Where**: [day 3 · Tests](../../en/libro/day3.html#compile-once-pick-the-test-from-the-command-line) ·
**Runs**: `make u4/tests` — one build, two tests

### 2 · What is the factory and what is an override for?

A directory from names to types. You register the class with
`` `uvm_component_utils ``, you create it with `type_id::create()` instead of
`new()`, and from then on **somebody from outside can ask for another class to
be built in that spot** without touching the env. That is the override:
changing the part without touching the plan. If you create with `new()`, the
override has no way in and it does not fail — it ignores you.

**Where**: [day 3 · the factory override](../../en/libro/day3.html#the-override-changing-the-part-without-touching-the-plan) ·
**Runs**: `make u4/env`

### 3 · What is the difference between `uvm_object` and `uvm_component`?

The component **is in the tree**: it has a parent, it has a hierarchical name,
it lives for the whole simulation and UVM runs the phases on it. The object does
not: it is created, used and thrown away. That is why a transaction and a
sequence are objects —there are millions of them and they are temporary— and a
driver or a monitor are components. The constructor signature gives it away:
`(name, parent)` against `(name)`.

**Where**: [day 6 · an object, not a component](../../en/libro/day6.html#an-object-not-a-component)

### 4 · Name the phases. Which one consumes time?

There are nine, not five: `build`, `connect`, `end_of_elaboration`,
`start_of_simulation`, `run`, `extract`, `check`, `report`, `final`. **The only
one that consumes simulation time is `run_phase`**, and it is the only one that
is a `task`; the rest are `function` and run in zero time. `build_phase` goes
top-down —the parent before the child, because the parent builds the child— and
`connect_phase` bottom-up.

**Where**: [day 3 · the full picture](../../en/libro/day3.html#the-full-picture-there-are-nine-not-five) ·
**Runs**: `make u4/components`

### 5 · How does UVM know when to end the simulation?

By the **objections**. Every `run_phase` runs in parallel, so none of them can
decide on its own: whoever has work raises an objection with `raise_objection`,
and the phase ends when the last one drops. Without a `raise` the simulation
ends at **t = 0** and the test passes with 0 errors without having sent any
stimulus; without a `drop` it never ends. Both symptoms are silent, and that is
why `+UVM_OBJECTION_TRACE` and `+UVM_TIMEOUT` exist.

**Where**: [day 3 · objections](../../en/libro/day3.html#objections-who-decides-when-it-ends)

### 6 · The test finished and the last transactions were not compared. Why?

Because the objection says *"I am done **sending**"*, not *"I am done
**comparing**"*. Between the two there is a scoreboard with a FIFO inside and
transactions in flight. You fix it with a `drain_time` —a cushion after the last
`drop`— or, better, with `phase_ready_to_end()`, which lets the component that
still has work raise one more objection. It is the bug of the second week and it
reports nothing.

**Where**: [day 3 · the end that is not the end](../../en/libro/day3.html#the-end-that-is-not-the-end-drain_time)

---

## Structure: who is who in the tree

### 7 · What is the `uvm_config_db` and why does the `get` go in the `build_phase`?

A global and **typed** database —the `#(...)` is part of the key— with
hierarchical scope. The `set` in the top goes before `run_test()`, because
before that line there is not a single UVM object alive. The `get` goes in
`build_phase` and **not** in the constructor, because when the constructor runs
the tree is still being built. And always inside an `if` with its `uvm_fatal`:
the `get` returns a bit, and ignoring it leaves a `null` that blows up three
layers further down.

**Where**: [day 3 · the testbench's mailbox](../../en/libro/day3.html#uvm_config_db-the-testbenchs-mailbox)

### 8 · What is a virtual interface and why is it needed?

Classes cannot see the signals of a module: the interface is instantiated in the
`top`, which is hardware, and the test is an object created at simulation time.
The virtual interface is the handle that crosses that border, and it travels
through the `config_db` because the `uvm_component` constructor only takes
`(name, parent)` and there is no other way to hand it over.

**Where**: [day 3 · the top](../../en/libro/day3.html#the-top-instantiate-publish-the-interface-start)

### 9 · What is inside an agent? What changes between active and passive?

Sequencer, driver and monitor. **The passive one builds neither the sequencer
nor the driver**: it only watches. It is picked with `is_active`, which travels
in a configuration object, and it is what lets you plug the agent onto a bus
somebody else drives —a legacy module, the designer's testbench— and verify it
without driving it. The agent is the unit of reuse: it is what gets bought, sold
and copied between projects.

**Where**: [day 6 · what is inside an agent](../../en/libro/day6.html#what-is-inside-an-agent) ·
**Runs**: `make u7/agents`

### 10 · What is an analysis port and who is a subscriber?

The *observer* pattern turned into a library: the monitor **publishes** with
`write()` and does not keep the list of who is listening; the subscribers
implement `write()` and hook themselves up in the `connect_phase`. One port can
have several destinations and it costs nothing. The design consequence is the
one that matters: **on one side of the monitor you speak signals and on the
other, transactions**, and adding an observer is one line.

**Where**: [day 4 · analysis ports](../../en/libro/day4.html#a-single-place-that-watches-the-wire-1) ·
**Runs**: `make u5/analysis-ports`

### 11 · Can the `write()` of a subscriber wait for an edge?

No. It is a `function`, and a `function` consumes no time: the whole chain —the
BFM's `always` → `ap.write()` → the subscribers' `write()`— happens in a single
instant. When the consumer needs to make the producer wait, the piece is the
`uvm_tlm_fifo` with `put`/`get`, which are `task`s.

**Where**: [day 4 · put and get](../../en/libro/day4.html#non-blocking-communication)

---

## Stimulus: sequences

### 12 · Walk me through the handshake between the sequence and the driver.

The sequence calls `start_item(t)` —which blocks until the driver is free—,
fills or randomizes the item, and calls `finish_item(t)`. On the other side the
driver calls `get_next_item(t)`, drives the wires, and **`item_done()`**. If the
driver forgets the `item_done()` there is no error: the sequence waits forever
and the simulation hangs.

**Where**: [day 6 · the handshake](../../en/libro/day6.html#the-handshake-get_next_item--item_done)

### 13 · How do you give the result back to the sequence?

By writing it **inside the same item**, before the `item_done()`. That is the
way back, and it is what makes reactive stimulus possible: the Fibonacci
sequence of the course needs the result of the previous operation to build the
next one.

**Where**: [day 6 · the item comes back with the result inside](../../en/libro/day6.html#the-item-comes-back-with-the-result-inside) ·
**Runs**: `make u7/sequences`

### 14 · You have two sequences on the same sequencer. Who decides the order?

The sequencer, and it arbitrates **per item**, not per sequence. Priority is the
third argument of `start()`, but the default mode —`UVM_SEQ_ARB_FIFO`— **does
not look at it**: you have to ask for
`set_arbitration(UVM_SEQ_ARB_STRICT_FIFO)`. And when the scenario cannot be
interleaved —a read-modify-write— you use `lock()` (queues up) or `grab()`
(cuts in line), always with its `unlock()`.

**Where**: [day 6 · the arbitration](../../en/libro/day6.html#two-sequences-on-the-same-sequencer-the-arbitration)

### 15 · What is a virtual sequence and when do you need one?

When there is **more than one sequencer** and the scenario crosses them. It
sends no items of its own: it takes the handles out of a `virtual_sequencer` and
coordinates —in a `fork` or in series— the sequences of each interface. The case
that justifies it is the one with a piece of data that crosses over: configure
through one bus, read the status, and only then send traffic through the other
one with whatever the configuration returned.

**Where**: [day 7 · virtual sequences](../../en/libro/day7.html#virtual-sequences) ·
**Runs**: `bash code/u7/sequences/virtual/run.sh`

---

## Checking and coverage: the part that sorts people out

### 16 · Code coverage and functional coverage, how do they differ?

The simulator gives you code coverage for free and it says **what RTL was
executed**. Functional coverage is the one you write and it says **which
scenarios from the spec happened**. The first one misleads: a test that always
sends the same operation executes almost every line of the adder and verified
nothing, and a DUT that is missing a whole feature can score 100 % of lines —
the lines nobody wrote do not show up in the report.

**Where**: [day 1 · when are you done verifying?](../../en/libro/day1.html#when-are-you-done-verifying) ·
**Runs**: `make u2/convencional`

### 17 · You have 100 % functional coverage. Are you done?

No, and there are three reasons to say so out loud. **`option.at_least`
defaults to 1**, so a bin that happened once already counts as covered. An
unfiltered `cross` inflates the denominator with combinations that are in no
spec. And above all: coverage measures **the plan**, and if a case from the spec
has no bin, nobody is going to find out it is missing. The number is not the
goal; the useful question is *which* bin is missing.

**Where**: [day 1 · the knobs](../../en/libro/day1.html#the-knobs-when-a-bin-counts-as-covered)

### 18 · `ignore_bins` and `illegal_bins`, when does each one apply?

`ignore_bins` takes the bin out of the count: it is for what **cannot** be
covered, and it is executable documentation —it says out loud what does not get
measured, and why—. `illegal_bins` takes it out of the count *and* reports an
error if it ever happens: it is for what the spec **forbids**. And if it simply
has not happened yet, neither of them applies: what that needs is a test.

**Where**: [day 1 · ignore_bins](../../en/libro/day1.html#ignore_bins-saying-out-loud-what-does-not-get-covered)

### 19 · When does an assertion apply and when does the scoreboard?

The scoreboard checks **the result**: the functional spec, the what. The
assertion checks **the protocol**: timing rules verified where they happen,
cycle by cycle, inside the interface. The rule of thumb is the latency one: if
the rule talks about *when*, it is a property; if it talks about *how much*, it
is the scoreboard. And every assertion goes with its `cover property`, because
an assertion that never fires passes green without checking anything.

**Where**: [day 7 · assertion or scoreboard](../../en/libro/day7.html#assertion-or-scoreboard-the-same-rule-two-places) ·
**Runs**: `make u8/assertions`

### 20 · The DUT answers you out of order. How do you compare?

The FIFO is no use any more: as soon as two responses cross, the comparison
pairs the response of one with the request of another and the scoreboard shouts
on **all** of them. The pattern is an **associative array indexed by whatever
pairs them up** —the transfer ID—, a `delete` once compared, and a check at the
end that the array came out empty. That last check is half the value: what is
left inside are the requests the DUT never answered.

**Where**: [day 4 · when the DUT does not answer in order](../../en/libro/day4.html#when-the-dut-does-not-answer-in-order)

---

## The one that always comes at the end

### 21 · How do you debug a testbench that does not work?

With this table, which is the one from the day 7 appendix and is worth knowing
by heart. The golden rule is in the second column: **suspect number one is never
the DUT, it is the testbench watching it.**

| The symptom | The first suspect | What to look with |
| --- | --- | --- |
| Ends at **t = 0** and says PASS | nobody raised the objection | `+UVM_OBJECTION_TRACE` |
| **Never ends** | an `item_done()` that was not called | `+UVM_TIMEOUT=5000000,NO`, and then the trace |
| The scoreboard **shouts on all of them** | the monitor samples wrong | `+UVM_VERBOSITY=UVM_HIGH` |
| The `config_db` **finds nothing** | the scope of the `set`, not the `get` | `+UVM_CONFIG_DB_TRACE` |
| Coverage reads **0 %** | the `new()` or the `sample()` is missing | `verilator_coverage` on the `.dat` |
| The tree **is not the one you drew** | a `create()` without the factory | `print_topology()` |

**Where**: [day 7 · the debug toolbox](../../en/libro/day7.html#which-one-to-use-according-to-the-symptom) ·
**And also**: [`silent-traps.md`](silent-traps.md), which is the list of
everything that compiles, runs and lies

---

## What they will not ask you, and will look at anyway

None of these is a UVM question, and the three of them weigh more than all the
previous ones.

- **Have you ever written a verification plan?** It is the deliverable that
  separates whoever ran tests from whoever verified something. The template and
  the filled-in example are in
  [`verification-plan.md`](verification-plan.md), and
  the capstone of the course is handed in with the plan filled out — which is
  exactly what gets handed in on a project.
- **Can you show me something that runs?** A UVM testbench over a bus, written
  from scratch, with its covergroup and its scoreboard, in a public repository.
  That is the day 7 capstone: `code/ejercicios/d7-final/`.
- **How do you know your scoreboard works?** The right answer is *"I injected a
  bug into the DUT and it shouted"*. A scoreboard that never saw an error is not
  tested, and the capstone marker verifies it by running both ways.

---

## And if you come without the course

The questions are ordered from most to least frequent inside each block, and the
blocks in the order in which they get asked. If you have one afternoon: 1, 4, 5,
7, 9, 12 and 21. If you have a week, the whole course is about 34 hours and all
of it runs on your machine — [README](../../README.md).
