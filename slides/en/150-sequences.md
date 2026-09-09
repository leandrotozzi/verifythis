<!-- es-sha: 6867b357cfd7 -->
## Sequences

#### *The only thing left hard-wired*

- The agents left the testbench encapsulated: one `agent` per interface, the
  analysis in the `env`, and nobody naming somebody else's components
- Except for one line, the one in the `run_phase` of the test:

```systemverilog
seq.start(env_h.clase_agent_h.sequencer_h);
```

- The test **goes across the hierarchy** to reach the sequencer, and along the way it gets to know
  the inside of the `env` we have just closed
- And there is something bigger behind it: that `command_sequence` is **one** class doing
  **three** things — resetting, sending a thousand random operations and one directed
- This section is about what happens inside `body()`, and about how a
  sequence gets started without wiring it

Note:
The sentence that orders the whole section: **stimulus is not structure**.
A component is built once, before the simulation starts, and it
stays there until the end. Stimulus changes from test to test, and sometimes it changes
inside the same test. Transactions, agents and sequences are the same operation repeated
on three different things: separating the **data** (transaction), separating the
**structure** (agent), separating the **stimulus** (sequence).
The question to throw at the group before going on: with the `command_sequence` of the
agents, how many classes are needed to try three stimuli and their combinations?
Six, and it grows factorially. In the *UVM Primer* that is called *explosion of tester
classes*.

---

## Sequences

#### *An object, not a component*

![The sequence lives outside the component tree; the sequencer, inside](res/diagrams/en/sequences_donde_vive.svg)
<!-- .element: class="grande" -->

- The `uvm_sequencer` is a `uvm_component`: **it is in the tree**, it has a parent,
  it has phases, the `build_phase` of the agent builds it
- The `uvm_sequence` is a `uvm_object`: **it is not in the tree**, it has no parent,
  it has no phases, and it gets created with a single argument — just like the transactions
- Practical consequence: it gets created, runs, finishes and is thrown away. You can run another one
  right after, or two at once, without touching the structure

Note:
There is a detail here that confuses and is worth getting ahead of, because they are going to see it in the
log: even though the sequence is not in the tree, UVM reports it **hanging off the
sequencer**, with an `@@` in the middle:
`uvm_test_top.env_h.clase_agent_h.sequencer_h@@full_seq.random_seq`
That does NOT mean it is a child of the sequencer. The `@@` is precisely the mark that
what follows is a sequence and not a component: to the left, the path of the
sequencer it runs on; to the right, the path of nested sequences. If
somebody looks for `sequencer_h.full_seq` with `uvm_root::get().find()` they are never going to
find it.
The other consequence, the one used every day: since it is not a component, a
sequence can have configurable fields that get changed **between** the `create()`
and the `start()`. That is what `full_seq.count = 200` does two slides
further on, and with a component it could not be done: by the time you want to change it, the
`build_phase` has already gone by.

---

## Sequences

#### *The smallest sequence there is*

{{code:code/u7/sequences/tb_classes/reset_sequence.svh}}

- It extends `uvm_sequence #(T)`, parameterized with the item it is going to send
- It gets registered with `` `uvm_object_utils `` — **not** with `` `uvm_component_utils ``
- Constructor with a single argument: `name`, without `parent`
- All the work lives in `body()`, which is a **task**: it can block
- Nobody calls `body()` by hand: UVM calls it when somebody starts the sequence

Note:
The two typing mistakes everybody makes the first time, and which give
messages that do not help:
1. `` `uvm_component_utils `` instead of `` `uvm_object_utils ``. The error talks about
   a constructor with two arguments and nobody relates it to the macro.
2. `function body()` instead of `task body()`. The declaration compiles, and then
   the `start_item()` inside does not, because a function cannot block.
And a design one worth marking: the `command` is declared **inside**
`body()`, not as a field of the class. In the *UVM Primer* it is a field. If it is a field,
two runs of the same sequence share the handle, and the day somebody
starts the same sequence twice in parallel you have two threads writing the
same object.
And a protocol one, which is what makes this sequence exist: **the first item
of every test is a reset**. The VTALU starts up with `reset_n` at 0 and never raises
`done`; the driver stays in its `while (bfm.done == 0)` and the sequence, in the
first `finish_item()`. There is no error: the simulation stops advancing. It is the same
symptom as the forgotten `item_done()`, with another cause, and it is worth showing it once
in class by deleting the `reset_sequence` from `full_sequence`.

---

## Sequences

#### *The handshake, now from the sequence side*

![Timeline of start_item, get_next_item, item_done and finish_item](res/diagrams/en/sequences_handshake.svg)
<!-- .element: class="grande" -->

- The same four calls as the agents, looking at the other lane:
  `start_item()` blocks the **sequence** until the sequencer gives it the turn,
  and `finish_item()` blocks it until the `item_done()` of the driver
- Simulation time advances **only** in the amber bar: filling the item does not
  cost a clock edge
- Two threads, four calls and no `#delay` in the middle

Note:
Confusion number one of the section: believing that `finish_item()` comes back when the
item **was delivered**. No: it comes back when the driver called `item_done()`, that is
when the operation **finished in the DUT**. It is the difference between "I sent it" and
"it is done", and it is what makes Fibonacci possible four slides further on.
Out of that comes as well why the `#500` that the `tester` of the transactions
had at the end disappeared: it was not stimulus, it was a patch so the objection would not drop
before its time. With `finish_item()` the stimulus no longer gets cut in half. Careful,
honesty: the **last** result can still end up uncompared, because the
objection gets dropped as soon as `start()` comes back and the `result_monitor` publishes one edge
later. It can be seen in the log of the `add_test`: 1001 commands, 1000 comparisons.
If somebody asks about the non-blocking cousin: there is `try_next_item()`, which
comes back right away with `null` if the sequencer has nothing. It is the same
`get()` / `try_get()` pair from the communication between threads and it is useful when the protocol forces you to drive
the bus even when there is no stimulus — idle cycles, refresh of a DRAM. The VTALU does not
need it: between one operation and the next the signals can stay still.

---

## Sequences

#### *What happens between `start_item()` and `finish_item()`*

{{code:code/u7/sequences/tb_classes/random_sequence.svh#body}}

- When `start_item()` comes back, the sequence **already has the turn** of the sequencer:
  nobody else is going to beat it to the driver
- Only then do the fields get filled, or the randomize happen. That is **late
  randomization**: the values get chosen at the last possible moment
- It is useful because by then it is already known what state the DUT is in, and a
  constraint can depend on that
- `randomize()` still goes with its `else`: it returns 0 and aborts nothing — it is the
  same thing they saw in the Constrained random unit

Note:
The honest question: "and what if I randomize before `start_item()`?". It works. On a
small testbench you do not notice the difference.
You notice it when the sequence has a thousand items queued up and a constraint depends on
something that changes during the run —an address that has already been written, a buffer
that has filled up, the previous result—. If you randomized everything at the beginning,
you decided with old information.
The other reason, more practical: between `start_item()` and `finish_item()` is where UVM
calls `pre_do()` and `mid_do()`, which are the hooks people use to
inject errors without touching the original sequence. If you fill the item before, those
hooks have nothing to do.
And the hook back to day 5: this is where the `randomize() with {}` of the coverage
closure goes. The directed case gets asked for at the point of use, without writing a new
class. The slide that follows is exactly that, with the Verilator trap included.

---

## Sequences

#### *Directed late randomization, and the Verilator hole*

```systemverilog
start_item(command);
command.data.constraint_mode(0);                       // 1. I switch off the dist
if (!command.randomize() with {A inside {[1:10]};})    // 2. I ask for the directed one
   `uvm_fatal("SEQ", "randomize() failed")
finish_item(command);
```

- Measured with Verilator 5.052, on a class with the constraints of
  `command_transaction`, 100 randomizations of each form:

```sh
with {op == mul_op}                       100 of 100   op has no dist
with {A inside {[1:10]}}                    1 of 100   A does have one
constraint_mode(0) + with {A inside ...}  100 of 100   the way around it
```

- The rule, in one line: **if the `with {}` touches a field that has a `dist`,
  switch that constraint off first**
- It is not the language, it is the tool: `repro-dist-with.sv` in
  `code/verilator/`

Note:
It is the same limitation they already saw in the Constrained random unit, but here
it shows up in the place where they are really going to use it, so it is worth measuring it
again against the real transaction.
What the measurement adds on top of what `docs/verilator.md` says: the trigger is
not "there is a `dist` in the class". It is **the `with {}` restricting a field that has a
`dist`**. Asking for `op == mul_op` works perfectly, even though `A` and `B` have `dist` in the
same resolution. That is why the sequences of the section do not run into this: none of them
uses `with {}`.
And the way around it is not a concession: for a directed case, switching off the distribution
constraint is the right thing anyway. The `dist` is there so the random hits the
edges; if you already know which value you want, it has nothing to contribute.
`constraint_mode(0)` is per **object**, not per class, and the object gets thrown away after
`finish_item()`: there is no need to remember to switch it back on.

---

## Sequences

#### *The item comes back with the result inside*

{{code:code/u7/sequences/tb_classes/driver.svh#run_phase}}

- The driver writes `command.result` **before** calling `item_done()`
- The sequence still holds the handle to that same object: when `finish_item()`
  comes back, the result is there
- It is the way back, and that is why `command_transaction` gains a field `result`
  in this unit — the only change to the transaction since it was created
- It breaks *MOOCOW* on purpose: the driver modifies an object it did not create. It is
  agreed between the two parties, and it is the only place in the testbench where it is done

Note:
This is the subtlest point of the section and it is worth saying it slowly: **there is
no way back at all**. There is no port, there is no FIFO. There is a shared
handle, and the two parties agreed that the driver writes and the
sequence reads, and that the safe moment to read is after `finish_item()`.
If somebody asks "wasn't the rule to clone?": yes, that is the rule of the transactions, and this is the documented exception. UVM has besides a formal
mechanism for this —the REQ/RSP pair of `uvm_sequence #(REQ, RSP)` with
`put_response()` on the driver side and `get_response()` on the sequence side—
that almost nobody uses, because writing the result into the request is enough in the
vast majority of cases. It is worth naming so they recognise it if they see it.
An implementation detail that does matter: the `send_op` reads `bfm.result` on the
same edge on which it sees `done` high. One edge later the DUT has already started the
next operation.

---

## Sequences

#### *Fibonacci: when the stimulus depends on the result*

{{code:code/u7/sequences/tb_classes/fibonacci_sequence.svh#body}}

- Every addition needs the result of the previous one: without a way back this cannot
  be written
- `finish_item()` comes back **after** the ALU has finished, so
  `command.result` is already valid
- It is the same `env`, the same agent, the same driver and the same BFM as the random
  test. Only the sequence changes

Note:
Fibonacci is not there to teach Fibonacci: it is there to force the case where the
stimulus N+1 depends on the result N. A test like that with the `tester` of the transactions
is impossible without giving the tester a handle to the monitor, that is without breaking
the separation we had been building.
Numbers for the blackboard: 0 1 1 2 3 5 8 13 21 34 55 89 144 233. It stops at 233
because the next one is 377 and `A` and `B` are 8 bits. Having the student see why the
`for` goes up to 14 and not up to 20 is worth more than the whole sequence.
And one that is seen in the real run: the whole test takes **500 units of
time**, against the 44,000 of the random test. Thirteen operations. A well-written directed
test is cheap; what is expensive is the random, and that is why it runs at night.

---

## Sequences

#### *Sequences that call sequences*

![full_sequence starting three sub-sequences on the same sequencer](res/diagrams/en/sequences_subsequences.svg)
<!-- .element: class="grande" -->

- A sequence can start others: it is the way of composing stimulus without
  duplicating code
- The `command_sequence` of the agents, split into three pieces that now get
  combined however you like
- The sequencer arbitrates: whatever it receives, it hands the driver **one item at a
  time**

Note:
The idea of the slide is that a sequence is not a special layer: it is an object with
a `body()`, and inside a `body()` another sequence can be started just the way
the first one is started. There is no nesting limit nor a different class for
"sequence that calls sequences".
The practical consequence, which is the one that counts: stimulus gets composed like
functions. A small sequence —"write the four registers", "send a maximum
multiplication"— gets written once and afterwards goes into any
scenario. It is exactly what in the conventional testbench was done by copying and
pasting blocks of the tester.
The last bullet is the one that avoids the most common misunderstanding: that three sequences
are composed does **not** mean that their items get mixed on the bus. The
sequencer hands over one at a time, and if two sequences compete on the same
sequencer there is an arbitration policy deciding. With sequences nested
on a single sequencer, the order is the one the `body()` says.

---

## Sequences

#### *`full_sequence`: three pieces, one single sequencer*

{{code:code/u7/sequences/tb_classes/full_sequence.svh#body}}

- `get_sequencer()` returns the sequencer that `start()` handed to **this**
  sequence: the daughters run on the same one
- The second argument, `this`, declares them **daughters**. Without it they compete with
  the mother in the arbitration instead of inheriting her turn
- `random_seq.count = count` is the advantage of the sequence being an object: it gets
  configured between the `create()` and the `start()`
- To run two in parallel, `fork` / `join` around the `start()`, and the
  sequencer interleaves the items

Note:
`get_sequencer()` is the accessor of IEEE 1800.2; the field is called `m_sequencer` and
the *UVM Primer* uses it directly. Both forms work — the `get_` one is the one worth
teaching, because `m_` is the UVM convention for "this is internal".
And if somebody has already read production code they are going to ask about `p_sequencer`: it is a
**typed** handle to the sequencer, which shows up when you use
`` `uvm_declare_p_sequencer(mi_sequencer) ``. It is only useful if you extended
`uvm_sequencer` to put something of your own in it, because `m_sequencer` is of type
`uvm_sequencer_base` and does not see those fields. Since in this course the sequencer is a
bare `typedef`, `p_sequencer` contributes nothing.
The second argument of the `start()` is the one almost nobody puts in and that almost always
matters: without a parent, if mother and daughter ask for the turn at the same time the sequencer
treats them as two independent sequences. With a parent, the daughter inherits priority and
context.
If they ask about the order with `fork`/`join`: the default arbitration is
`UVM_SEQ_ARB_FIFO`, that is order of arrival. It gets changed with `set_arbitration()` of the
sequencer, and there are six modes, one of them with weights.

---

## Sequences

#### *Starting a sequence, form 1: `start()`*

{{code:code/u7/sequences/tb_classes/full_test.svh#run_phase}}

- `start(sequencer)` hands the sequence the sequencer it is going to run on
  and **does not come back until `body()` has finished**
- The test raises the objection before and drops it after: the run lasts
  exactly as long as the stimulus lasts
- It is explicit and reads top to bottom. For a test that runs a single
  sequence, it is what suits
- And it still has the problem of the first slide: `sequencer_h` came out of
  `env_h.clase_agent_h.sequencer_h`

Note:
`start()` does three things, in this order: it saves the sequencer (it is what
`get_sequencer()` returns afterwards), it calls `pre_body()` / `body()` / `post_body()`, and it
comes back.
The detail to underline: the objection is raised by **the test**, not by the
sequence. The sequence knows nothing about phases. That is on purpose — the same
sequence has to be able to run inside another sequence, where raising an
objection would make no sense, and in fact that is what `full_sequence` does with its
three daughters.
The `sequencer_h` is resolved by `base_test` in `end_of_elaboration_phase`, not in
`build_phase`: during the `build_phase` of the test the agent has not built its
sequencer yet. It is the same reason why the connections go in `connect_phase`.

---

## Sequences

#### *Form 2: `default_sequence` through `uvm_config_db`*

{{code:code/u7/sequences/tb_classes/default_seq_test.svh#build_phase}}

- The test **has no `run_phase`**: the sequencer starts the sequence on its own, when
  the phase begins
- The instance name carries the suffix `_phase`: `"...sequencer_h.main_phase"`
  means *"in the `main_phase` of that sequencer"*
- It can be configured per **instance** (as here, with
  `uvm_config_db #(uvm_sequence_base)`) or per **type**
  (`uvm_config_db #(uvm_object_wrapper)` + `get_type()`). The instance wins if
  both are there
- The sequencer stopped being a handle and became a **path**: that is already
  configuration, not code

Note:
**The trap, and it is one of the ones that give no warning.** Without the line
`set_automatic_phase_objection(1)`, nobody raises the objection of the `main_phase`.
And a phase without an objection finishes as soon as it starts.
What was tried with Verilator 5.052: the run finishes at **t=0**, prints the Report
Summary with **0 UVM_ERROR / 0 UVM_FATAL**, and exits with code 0. That is: the test
PASSES without having sent a single piece of stimulus. It is in `code/u7/sequences` as
`no_objection_test`, so it can be run in class alongside the good one.
It is exactly the same kind of bug as the `new()` that eats the override of the transactions: it does not break, it **lies**. And in a regression of a thousand tests, a test that passes
in zero seconds is one nobody looks at.
Fine detail: `main_phase` is the one to use, not `run_phase`, but not because
`run_phase` does not work — `uvm_task_phase::traverse` calls
`start_phase_sequence()` on **every** task phase (`base/uvm_task_phase.svh:121`), so
`"…sequencer_h.run_phase"` works just as well. The reason is one of coexistence: the
`run_phase` runs in parallel with the schedule reset → configure → main → shutdown,
and hooking onto `main_phase` puts the sequence inside that schedule instead of
alongside it.

---

## Sequences

#### *When to use which*

| | `seq.start(sqr)` | `default_sequence` |
| --- | --- | --- |
| Where it is written | `run_phase` of the test | `build_phase` of the test, or the `top` |
| Objection | the test handles it | `set_automatic_phase_objection(1)` |
| It reads | top to bottom | you have to go looking for it |
| Several sequences in order | trivial | one per phase |
| Changing it without recompiling | no | yes, it is a config |
| Knows the inside of the `env` | yes, through the handle | no, only the path |
| Reusable third-party agent | not always possible | it is the intended mechanism |

- For the tests of the course: **`start()`**, because it shows
- For an agent you hand over to another team: `default_sequence`, because it lets them
  change the stimulus without touching your code

Note:
In the industry both live side by side and the choice is almost always political, not
technical: `start()` when the one writing the test is the owner of the testbench,
`default_sequence` when the testbench belongs to somebody else.
A third way worth naming without developing: the same `uvm_config_db` from
the `top` module, with `null` as the context. There the stimulus gets chosen from the command
line and the testbench does not even get recompiled. That is how the big
regressions work.
And the row that matters for the arc of the section is the second to last: `default_sequence`
is what finishes closing the `env` that the agents encapsulated.

---

## Sequences

#### *The `` `uvm_do `` macro and why the course does not use it*

```systemverilog
`uvm_do(command)                         // one line

command = command_transaction::type_id::create("command");   // four
start_item(command);
if (!command.randomize()) `uvm_fatal("SEQ", "randomize() failed")
finish_item(command);
```

- `` `uvm_do `` does exactly those four things: create, `start_item`,
  randomize, `finish_item`
- What it hides: the `randomize()` **without an else**, so a constraint without a
  solution goes by in silence
- What it prevents: filling fields by hand between the two calls — that is, everything on
  the previous slides
- What it breaks: the error message points at the expanded macro, not at your code
- There is a whole family (`` `uvm_do_with ``, `` `uvm_create ``,
  `` `uvm_send ``) and the same argument holds for all of them

Note:
It is the same discussion as the `` `uvm_field_* `` macros of the transactions, and the
same conclusion: they save typing and charge you in debug.
It is worth being fair: `` `uvm_do_with `` is genuinely convenient for a one-line inline
constraint, and you are going to see it in every testbench in the world. You have to
know how to read it. What the course does not do is teach it first: whoever learns with
the macro does not know what happens between `start_item()` and `finish_item()`, and that is the whole
section.
A rule of thumb for work: read them all, write the explicit ones.

---

## Sequences

#### *The override still works, and no sequence found out*

{{code:code/u7/sequences/tb_classes/add_test.svh}}

- It is the same `add_test` as the transactions, word for word
- `random_sequence` still creates `command_transaction::type_id::create()`; the
  factory hands it back an `add_transaction`
- Measured result: 1000 operations, **all** `add_op`, 0 `UVM_ERROR`
- `maxmult_sequence` still sends `mul_op` under `add_test` — because it does not
  randomize, and **the constraint only acts on `randomize()`**

Note:
It is the best proof that the separation worked: changing the **data type** did not
require touching the stimulus, and changing the **stimulus** does not require touching the data
type. Two independent axes, which in the transactions were stuck together and in the agents
still shared a class.
And the last bullet is the review of the trap of the transactions, now in a place
where it can be seen running: the factory picks the TYPE, the constraints only act on
`randomize()`.

---

## Sequences

#### *Virtual sequences: the problem*

- A **virtual sequence** is a sequence that does not send items of its own: it only
  starts other sequences, on **several sequencers**
- It shows up when the DUT has more than one interface —a configuration bus and a
  data stream, for example— and the test needs to coordinate them: *configure
  first, then send traffic*
- It is called "virtual" because it is not tied to a type of item nor to a sequencer
- The `u7/agents` already left us the scenario built: **two VTALU**. There the second agent
  was passive; with both active there are **two sequencers**, and something to coordinate
- `full_sequence` is already half a virtual sequence: it sends no items of its own, it only
  starts others. The only thing it lacks is the second sequencer

Note:
It is worth starting from the problem and not from the syntax, because the syntax is
half a screen: what is hard to understand is why a new class is needed
when `full_sequence` already composes sequences.
The answer is the one in the last bullet, and it is geometric: a normal sequence
knows **one** sequencer, the one `start()` handed it. Anything that wants to talk to
two interfaces needs two handles, and those handles have to come from
somewhere.
The example runs and it is in `code/u7/sequences/virtual/`: it is the testbench of this
section with **two lines** changed in the `env`, and everything else by
reference. It is worth saying before showing the code, because it is half of the
argument: a virtual sequence does not change the structure of the testbench.

---

## Sequences

#### *The virtual sequencer: handles, not items*

{{code:code/u7/sequences/virtual/tb_classes/virtual_sequencer.svh#the-handles}}

{{code:code/u7/sequences/virtual/tb_classes/env.svh#wiring-the-sequencers}}

- It has no queue, it does not arbitrate, it does not talk to any driver. It is a `uvm_component`
  that exists in order to **hold the handles** and to live in the tree with a name
- It extends `uvm_sequencer` **without parameterizing it**: the default item is
  `uvm_sequence_item` and none ever gets sent
- The handles get assigned in the `connect_phase`, where the agents already exist

Note:
The question that comes up on its own: and why a component, if it is only two pointers?
For two reasons. One, so the sequence reaches it with `p_sequencer` instead
of looking it up by string. Two, because it has to be in the tree so the test
can start a sequence on top of it: `seq.start(env_h.virtual_sequencer_h)`.
The book resolves the handles with `uvm_top.find("*.env_h.sequencer_h")`. It still
works —`uvm_top` is there for compatibility, the current form is
`uvm_root::get()`— but looking components up by string is fragile: the day
somebody renames the `env_h`, the `find()` returns `null` and the fatal shows up
far from the change. Assigning them in the `connect_phase` **does not compile** if the name
changed, which is exactly what one wants.

---

## Sequences

#### *The virtual sequence: `p_sequencer` and two branches*

{{code:code/u7/sequences/virtual/tb_classes/coordinada_sequence.svh#p-sequencer}}

{{code:code/u7/sequences/virtual/tb_classes/coordinada_sequence.svh#the-fork}}

- `` `uvm_declare_p_sequencer `` declares `p_sequencer` **with the type of the
  virtual sequencer** and casts it on its own. Without it, `get_sequencer()` returns a
  `uvm_sequencer_base` and you have to cast by hand at every use
- The `fork`/`join` is over **two sequencers**: each branch blocks on its driver and
  the `join` waits for both
- That cannot be written inside a normal sequence, which knows a single
  sequencer

Note:
The `uvm_declare_p_sequencer` is sugar, and it is worth saying so: the only thing it does is
declare the variable and redefine `m_set_p_sequencer()` with the `$cast`. If the
sequencer it gets started on is not of that type, the fatal fires there and not
twenty lines later.
The detail that gets overlooked: the two branches of the `fork` start **different**
sequences on **different** sequencers. If they were two sequences on the
same sequencer, they would compete for the arbitration and the items would come out
interleaved — which is a legitimate scenario, but it is another one.
And a warning from the field: a virtual sequence with a single sequencer is a
normal sequence with more ceremony. The class is justified when there are two.

---

## Sequences

#### *What no sequence on its own can do*

{{code:code/u7/sequences/virtual/tb_classes/coordinada_sequence.svh#the-ordered-pair}}

- The result of VTALU **A** goes in as an operand of **B**: a dependency
  **between interfaces**, and in series. The second one cannot even be assembled until the
  first has answered
- The `result` comes back inside the item, which is the way back of this unit
- `0F × 07 = 105`, and B answers `106`. Run it: `code/u7/sequences/virtual/run.sh`

Note:
This is the slide that justifies the class. The two `fork` of the previous slide
could be imitated with two tests running in parallel; this one cannot, because there is a piece of data
that crosses from one interface to the other in the middle of the scenario.
It is exactly the shape of the real case the bus appendix promises:
configure over APB, read the status, and only then send traffic over AXI with
what the configuration returned. The protocol changes, not the structure.
And the honest close: the example runs on two VTALU because it is the DUT we
have. With two different interfaces —two transactions, two drivers— the
virtual sequence is written **the same**: the handles would be of two types of
sequencer, and nothing more.

---

## Sequences

#### *Two sequences on the same sequencer: the arbitration*

- Up to here every sequencer has had **one** sequence at a time. In a real testbench
  there are several in parallel on the same driver —background traffic, a directed
  test, an error injector— and somebody has to hand out the turns

```systemverilog
fork
   fondo_seq.start(sqr);                 // priority 100, the default one
   urgente_seq.start(sqr, null, 500);    // the third argument is the priority
join
```

| The mode, in `sqr.set_arbitration(...)` | How it hands out |
| --- | --- |
| `UVM_SEQ_ARB_FIFO` | order of arrival, and **the priority is not looked at** (default) |
| `UVM_SEQ_ARB_STRICT_FIFO` | the priority rules; at equal priority, order of arrival |
| `UVM_SEQ_ARB_WEIGHTED` | at random, with the priority as the weight |
| `UVM_SEQ_ARB_RANDOM` | at random, all equal |
| `UVM_SEQ_ARB_USER` | `user_priority_arbitration()`, you write it |

- The default **ignores the priority**: putting a 500 in and not changing the mode is the
  mistake of this slide, and nobody gives you a warning

Note:
The question that orders the slide is *"who decides which item goes into the driver?"*,
and until today the answer was "there is nobody to decide about". The sequencer arbitrates
**per item**, not per sequence: two sequences in a `fork` do not take turns in blocks,
they interleave item by item. It is worth saying because intuition says the opposite.
The mistake to leave engraved is in the last bullet and it is out of a manual: the
priority gets written, it gets run, and nothing happens — because `UVM_SEQ_ARB_FIFO` does not
look at it. Priority without `set_arbitration(UVM_SEQ_ARB_STRICT_FIFO)` is an
expensive comment.
`UVM_SEQ_ARB_STRICT_FIFO` is the one used 90 % of the time, and the name
confuses: *strict* is about the priority, not about the FIFO. It first orders by
priority and only within each level does it respect the order of arrival.
And the one almost nobody uses but is worth naming, because it explains what
`UVM_SEQ_ARB_USER` exists for: there are protocols where the turn depends on the state of the DUT —do
not send a write if the FIFO of the DUT is full—. That is not a priority, it is
a function, and that is what the user mode is for. The cousin of that idea is
`is_relevant()`, which keeps a sequence out of the arbitration until it
says itself that it is ready.

---

## Sequences

#### *`lock()` and `grab()`: when the arbitration is not enough*

- There are scenarios that **cannot be interleaved**: a configuration sequence,
  an atomic burst, a read-modify-write. If another sequence slips an item in the
  middle, the scenario stopped being the one you wrote

```systemverilog
task body();
   grab();                  // cuts ahead of everyone and closes the door
   ... the items of the scenario, with nobody in between ...
   unlock();                // ungrab() is the same method, under another name
endtask
```

- **`lock()` queues up**: it waits its turn like anybody else and only then closes
  the door. **`grab()` cuts in**: it goes ahead of everyone, even of the higher
  priority ones
- Both are released with `unlock()`. Without the `unlock()`, if the sequence is
  **still alive** the sequencer stays closed forever and without a single error; if its
  `body()` finishes, UVM takes it away and shouts `SEQFINERR`
- The rule: `grab()` for reset and error recovery —what cannot wait—,
  `lock()` for everything else, and the `unlock()` in the same `body()`

Note:
The difference between the two is one single word and it is worth saying it like this: `lock` is
polite, `grab` is rude. Both end up with the sequencer all to yourself; what
changes is whether you wait your turn or take it.
When it is really needed, because abusing this is a classic: only when the
scenario loses its meaning if something gets interleaved. A read-modify-write on a
register is the canonical example —if another transaction goes by between the read and the write,
the value you write is old—. Sending ten items in a row does not
need a lock: a sequence already guarantees that.
The two endings of the missing `unlock()` have to be told together, because one
warns you and the other does not. If the sequence holding the lock finishes its
`body()`, `uvm_sequencer_base::remove_sequence_from_queues`
(`seq/uvm_sequencer_base.svh:1258-1267`) takes the lock away from it and reports a
`UVM_ERROR SEQFINERR` — "should not finish before locks … are removed": annoying, but
with a name on it. The silent case is the other one: the sequence is still alive and
blocked on something else, and there the sequencer stays closed without anybody
saying a word. That is the one that sends you looking on the wrong side: the
simulation does not advance and the `+UVM_OBJECTION_TRACE` says nothing odd, because
the objection is fine — the one that is stuck is the driver, waiting for an item that
is never going to arrive. The tool that shows it is `+UVM_TIMEOUT` and then reading
who has the lock.
And the detail that saves an afternoon: `grab()` does not interrupt the item that is in
flight. It cuts in at the next arbitration, not in the middle of a handshake — which
is exactly what one wants.

---

## Sequences

#### *The testbench, complete*

![The final testbench: sequences, agent, sequencer, driver, monitors and the analysis layer](res/diagrams/en/sequences_tb_completo.svg)
<!-- .element: class="grande" -->

- It is the diagram drawn today in any verification project, with the
  names used today
- Everything inside the `env` is built once and does not change. What
  changes between one test and another is the cloud of sequences at the top

Note:
The diagram shows **one** agent, which is the unit of reuse; in `code/u7/sequences` there are
two, the active one and the passive one of the agents, and the bottom one is identical except that
it has neither sequencer nor driver.
It is worth doing the count out loud: the conventional testbench was an `initial`
of a hundred lines that drove signals. This one has test, env, agent, sequencer,
driver, two monitors, coverage and scoreboard, and every piece can be replaced
without touching the others. And the three layers at the top —sequences, agent, analysis—
change for different reasons: the stimulus changes per test, the structure per
design, the analysis per verification plan.

---

## Sequences

#### *Summary of the unit · the sequence and the item*

- The stimulus came out of the component tree: it is a `uvm_object`, not a
  `uvm_component`, and that is why it gets created, configured, run and thrown away
- Everything happens inside `body()`, between `start_item()` and `finish_item()`: that is where the
  item gets filled, that is where the `randomize()` goes, and that is where `pre_do` and `mid_do` hook on
- The driver writes the result **inside the item** before `item_done()`: it is
  the way back, and it is what makes a stimulus that reacts possible
- Two ways of starting: explicit `start(sequencer)`, or `default_sequence` through
  `uvm_config_db` — which besides takes the last hard-wired line out of the testbench
Note:
The first half of the summary is the mechanism: what a sequence is, where the
`randomize()` lives, and which way the result comes back. Anyone who got lost in
the unit catches up here.

---

## Sequences

#### *Summary of the unit · how they compose*

- Sequences compose: one calls others, in series or with `fork`/`join`
- And when there is **more than one sequencer**, the one that composes is a **virtual
  sequence**: it sends no items of its own, it takes the handles out of a `virtual_sequencer` and
  coordinates the two interfaces — `code/u7/sequences/virtual/`
- With **two sequences on the same sequencer** the one who hands out is the sequencer:
  priority and `set_arbitration(...)`, and `lock()`/`grab()` for the scenario that cannot
  be interleaved
- With this the testbench of the course is complete, and it is the way it is written
  today in the industry

Note:
Close of day 6. None of the pieces we did see is magic: we built them all by hand —the
observer of talking to several objects, the FIFO of put and get, the tester of
transactions— before UVM
handed them to us done. That is the reason the course goes in this order and does not start
with the `uvm_agent`.
And the best place to go on reading is `code/.uvm/src/`: by this point
`uvm_sequence_base.svh` can be opened and understood.
