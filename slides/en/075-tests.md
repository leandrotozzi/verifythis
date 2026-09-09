<!-- es-sha: f9904d3af165 -->
## Tests

#### *Compile once, pick the test from the command line*

- The object-based testbench has the stimulus **inside**: changing test means
  changing code and compiling again
- A thousand tests at five minutes of compilation each are **5000 minutes**: three
  and a half days of machine time to run nothing new
- UVM turns the order around: the testbench gets compiled **once**, and the test that
  runs is picked when the simulation starts

```bash
$ ./obj_dir/top/sim +UVM_TESTNAME=random_test
$ ./obj_dir/top/sim +UVM_TESTNAME=add_test     # the same binary
```

- That is what this unit buys, and what gets paid with the ceremony that
  comes: registration in the factory, a constructor with a fixed signature and phases

Note:
The arithmetic is UVM's commercial argument, and it is worth saying it with the numbers
in hand: it is not that the modular testbench is wrong, it is that it does not scale.
If possible, live: compile once and run the two lines above. Let them
see that the second one compiles nothing.
What gets collected from the object-based testbench: the testbench is already split into tester,
coverage and scoreboard, and that is why only the tester can be changed. What gets
paid up front: in the components those three classes stop being loose objects that
the test `new()`s and become components of the tree.

---

## Tests

#### *The top: instantiate, publish the interface, start*

{{code:code/u4/tests/top.sv#run-test}}

- The `top` is still a **module**: it instantiates the BFM and the DUT the same as
  before. The only new thing is these two lines
- `run_test()` with no argument means *"whichever `+UVM_TESTNAME` says"*. With an
  argument —`run_test("random_test")`— that one becomes the **default**, and
  `+UVM_TESTNAME` still overrides it from the command line
- Before `run_test()` there is not a single UVM object alive: that is why the `set` goes here

Note:
The virtual interface gets passed through the config_db because classes do not see the
signals of the module: `bfm` lives in `top`, and `random_test` is an object that gets
created at simulation time. There is no way to hand it over through the constructor —
`uvm_component`'s constructor only accepts `name` and `parent`.
It is worth pointing at the order: first the `set`, then `run_test()`. The other way round
the test gets built before the data is in the database and the `get` fails with
the fatal. It is a mistake you rarely see because almost nobody writes the top the wrong way
round, but it explains why the `set` cannot go in a separate `initial`.
The slide that follows is the one to explain well: it is mistake number one of
whoever starts with UVM.

---

## Tests

#### *uvm_config_db: the testbench's mailbox*

- A global and **typed** database: the `#(...)` is part of the key
- Four arguments: *scope* (`cntxt`, `inst_name`), *name* and *data*
- The **scope** is a hierarchical path, and that is where the whole point is

{{code:code/u4/tests/config_db.svh}}

Note:
The first two arguments are *where*, the third is *what*. In the `set` of the
top it is `null, "*"` because `top` is a module, it is not in the UVM tree: the
translation is "from the root, visible to everybody".
In the `get` it is `this, ""`, that is, "me". It is worth writing on the board the
path that comes out: `uvm_test_top.env_h.driver_h`.
And the shortcut to warn against from the start: `get(null, "*", ...)` also
compiles and also works — it searches the whole tree and keeps the first thing it
finds. With a single interface you never notice. The day the testbench
has two, the driver of bus A can end up driving bus B, and it does not fail:
it lies. It is one of those mistakes that get paid for three months later.

---

## Tests

#### *A test in three parts: 1 · register it*

{{code:code/u4/tests/tb_classes/random_test.svh#class-head}}

- `random_test` extends `uvm_test`, which extends `uvm_component`: it is a node
  of the tree, not a loose object
- The `` `uvm_component_utils `` macro **enrols it in the factory**. Without that
  line, `+UVM_TESTNAME=random_test` finds nothing and UVM aborts
- The handle to the virtual interface gets **declared** here and **filled in** in the
  `build_phase`: they are two different moments

Note:
It is the first time the factory shows up for real, and you still cannot see what it is
for: here it only acts as a directory of names. The second half —creating by type
and being able to substitute it from outside— arrives in the env with the overrides.
The semicolon after the macro is redundant and UVM tolerates it. It is in the code of the
book and we left it the same so that whoever compares does not get dizzy, but if somebody
asks: it is not needed.

---

## Tests

#### *2 · the constructor and the `build_phase`*

{{code:code/u4/tests/tb_classes/random_test.svh#constructor-and-build}}

- The constructor of a `uvm_component` has a **fixed signature**: `name` and `parent`,
  in that order, and `super.new(name, parent)` as the first line
- The `get` of the config_db goes in `build_phase`, **not** in the constructor: when
  the constructor runs the tree is still being assembled
- `if (!get(...)) uvm_fatal`: the `get` returns a bit. Ignoring it leaves the handle
  at `null` and the failure shows up a hundred lines later, in another file

Note:
The fixed signature is the first thing everybody breaks: a constructor with one
argument too many and the factory cannot create it, because it always calls with
`(name, parent)`.
`build_phase` is a phase, not a function you call yourself: UVM walks it
top-down over the already assembled tree. In this test you cannot tell yet, because the
tree is a single node; in the components, when the env builds its children, the
top-down order is what makes the parent exist before the child.
The fatal is not paranoia: without it, a typo in the name of the data —"bfm" against
"BFM"— gives a simulation that runs, sends not one stimulus and finishes with 0
errors.

---

## Tests

#### *3 · the `run_phase`: this is where the simulation happens*

{{code:code/u4/tests/tb_classes/random_test.svh#run_phase}}

- It is the same body as the `execute()` of the object-based testbench: tester, coverage and
  scoreboard, with the two observers in `fork ... join_none`
- What changes is **who calls it**: before it was called by the `top` module, now
  it is called by UVM when the run phase's turn comes
- The two new lines are the `raise` and the `drop` of the objection, which are the ones
  that decide when everything ends

Note:
It is worth showing it next to the `tb.execute()` of the object-based testbench: the stimulus did not
change by one line. The only thing we did was move it inside a class that
UVM knows how to create and call. That is the whole job of this unit.
`join_none` and not `join`: coverage and scoreboard are infinite loops that watch
the signals. If we waited for them to finish, it never finishes.
And the one people miss: the simulation does not last as long as the `run_phase` lasts, it lasts as
long as the objections last. That is what comes now.

---

## Tests

#### *Objections: who decides when it ends*

```systemverilog
task run_phase(uvm_phase phase);
   phase.raise_objection(this);    // "I still have work"
   ...                             // the stimulus
   phase.drop_objection(this);     // "done, as far as I am concerned it can end"
endtask
```

- Every `run_phase` runs **in parallel**: none of them can decide on its own
  when to finish. UVM counts, and the phase ends when the **last**
  objection drops
- Without `raise_objection` the simulation ends at **time 0**, and the test
  passes with 0 errors without having sent a single stimulus
- Without `drop_objection` it never ends: there is no error, the simulation just
  keeps running
- Both symptoms are **silent**, and that is why two plusargs exist:
  `+UVM_OBJECTION_TRACE` says who raised it and who dropped it, and `+UVM_TIMEOUT`
  puts a ceiling on the run

Note:
It is the mechanism that decides how long the simulation lasts, and it is the one that produces the
two classic hangs of the first week. Worth writing the two failures on the
board, because the student is going to see them before any DUT bug.
The rule of thumb: the objection gets raised by **whoever has work**, and dropped
by **the same one**. In this course it is always the test. Never raise it in a
component and drop it in another one — that is how a real testbench hangs.
And a third participant is missing, which is the next slide: the objection knows
when the test finished **sending**, not when the scoreboard finished
**comparing**. That is the difference the `drain_time` pays for.
And the day 6 hook: `set_automatic_phase_objection(1)` is this same thing, done
by the sequencer instead of by the test.

---

## Tests

#### *The end that is not the end: `drain_time`*

- The objection says *"I finished **sending**"*. It does not say *"I finished
  **comparing**"*: between the two there is a scoreboard with a FIFO inside and
  results the DUT has not answered yet
- When the last objection drops the phase cuts **at that instant**: what
  was left in flight does not arrive, nobody compares it, and the summary says `UVM_ERROR : 0`

```systemverilog
task run_phase(uvm_phase phase);
   phase.get_objection().set_drain_time(this, 200ns);  // a cushion after the last drop
   phase.raise_objection(this);
   ...                                                 // the stimulus
   phase.drop_objection(this);
endtask
```

- The `drain_time` is a number picked by eye. The version with a criterion is
  **`phase_ready_to_end()`**: UVM calls it when the last objection dropped, and the
  component that still has work raises one more and the phase carries on
- It is **the** bug of the second week, and it is silent: no error, no hang, and
  the last transactions were never compared

Note:
It is the flip side of the previous slide and it is worth saying it in those words: the
objection measures **the stimulus**, not the analysis. The test knows when it finished
sending; the scoreboard is the one that knows when it finished comparing, and nobody
asked it.
The `drain_time` is the cheap answer and it is enough for 90 % of the cases: a
fixed cushion after the last `drop_objection`, in the order of what the
DUT takes to answer. In this course it would be a couple of cycles; on a bus with latency,
whatever the spec says.
`phase_ready_to_end()` is the expensive answer and the one used in a serious
testbench, because it is not a number: the scoreboard looks at its own FIFO, and if it has
items left it raises one more objection. The shape is always the same —check
`phase.get_name() == "run"`, and raise only if something really is missing—, and the
trap has to be said: if whoever implements it never drops it, they hung the phase.
The third piece, for whoever wants to hook in at exactly that instant, is
`all_dropped`: a callback of the objection object that fires when the count
reaches zero.
And the hook forward: the scoreboard with a FIFO of the analysis ports is
exactly the case of this slide, and the capstone steps on it again.

---

## Tests

#### *The second test: the same thing, with another tester*

{{code:code/u4/tests/tb_classes/add_test.svh#run_phase}}

- `add_test` is `random_test` with **one different line**: `add_tester` instead
  of `random_tester`. Everything else repeats exactly as it is
- That repetition is real and it is ugly, and it is the debt the components pay: when
  the testbench is a tree of components, the test is going to build an `env` and it is not
  going to touch the stimulus
- For now it is worth seeing it copied: it is the problem that motivates what
  follows

Note:
The duplication should not be apologized for, it should be pointed at. The student has to
finish this slide with the feeling of "this cannot be right", because that
feeling is exactly the reason for the components and the env.
If somebody jumps ahead and proposes a base class with the common `run_phase` and a
virtual method to pick the tester: that is fine, and it is more or less what
`base_test` does in the sequences. Tell them so and move on.

---

## Tests

#### *How it gets run, and what it prints*

{{code:code/u4/tests/run.sh#the-run}}

{{code:code/u4/tests/output.txt|lines=1-13}}

- A single `vlt_uvm`, two `run_sim`: **one compilation, two tests**. That is all
  the unit promises, and here it is done
- `[RNTST] Running test random_test...` is UVM saying what it found in the
  factory under the name you passed it
- The *Report Summary* with `UVM_ERROR : 0` is the verdict: reporting takes it
  apart and explains where each row comes from

Note:
Worth running it live and timing it: the compilation takes minutes, the two
`run_sim` take seconds. That is the number that justifies all the ceremony of
the unit.
The `$finish at 46ns` at the bottom is from the first test; `add_test` ends at 41 ns.
Both send the same number of operations, but the multiplication takes more cycles
than the addition, so the time depends on what came out of the random.
And a useful warning: `UVM_ERROR : 0` means "nobody called
`uvm_error`", not "the DUT is fine". Here the scoreboard does report with
`` `uvm_error ``, so the count is worth something — but a scoreboard that never receives
anything gives exactly the same zero. Reporting shows how to tell them apart.

---

## Tests

#### *Summary of the unit*

- The testbench gets compiled **once** and the test gets picked from the command line:
  `+UVM_TESTNAME=random_test`. That is the whole business of the section
- The arithmetic that justifies it: a thousand tests at five minutes of compilation each are
  **three and a half days** of waiting for it to compile
- The `top` is still a module. It publishes the BFM in the `uvm_config_db` **before**
  `run_test()`, because before that line there is not a single UVM object alive
- The **`uvm_config_db`** is a global and **typed** database: the `#(...)`
  is part of the key, and the scope is a **hierarchical path**
- A test gets registered with `` `uvm_component_utils ``. Without that line, the factory
  does not find it and UVM aborts
- The virtual interface gets **declared** in the class and **filled in** in the
  `build_phase`: they are two different moments, and confusing them leaves a `null`
- The objection says when the test finished **sending**, not when the scoreboard
  finished **comparing**. That difference is paid for with `drain_time`, or else with
  `phase_ready_to_end()`

Note:
Closing of the first real UVM unit. It is worth acknowledging the discomfort out
loud: today they put in a lot of ceremony to do the same thing they were already doing. What
they bought is the first bullet, and it does not pay out until there are two tests — which is the env.
The mistake they are going to walk into and it is worth anticipating: the `get()` that forgets to
check the return value. It does not fail, it **lies**: it leaves the virtual interface at
`null` and the testbench falls over three layers further down. That is why every `get` of the
course goes inside an `if` with its `uvm_fatal`.
