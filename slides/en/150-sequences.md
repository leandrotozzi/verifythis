<!-- es-sha: fd3d44b98f43 -->
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

#### *The formal way back: `get_response()`*

```systemverilog
// The sequence declares TWO types, and the response is no longer the request
class fib_sequence extends uvm_sequence #(command_transaction, result_transaction);
   start_item(cmd);
   finish_item(cmd);
   get_response(rsp);              // blocks until the driver answers

// And the driver, on the other side:
   seq_item_port.get_next_item(req);
   rsp = result_transaction::type_id::create("rsp");
   rsp.set_id_info(req);           // without this the response does not find its sequence
   seq_item_port.item_done(rsp);   // or item_done() now and put_response(rsp) later
```

- The shared handle of the previous slide holds as long as the driver is
  **blocking and serves one at a time**. The course's one is
- A *pipelined* driver calls `item_done()` as soon as it pushes the command and the response
  arrives N cycles later: by then the sequence has already sent another item, and
  writing into `req.result` writes **to the wrong item**
- `set_id_info(req)` copies the sequence and transaction id onto the response.
  It is what makes `get_response()` know who to answer
- The other two cases where it is needed: a VIP that **clones** the item, and a
  protocol with **more than one response** per request

Note:
This is the half slide that avoids a poor answer in an interview. The
question sounds like *"how do you give the data back to the sequence?"*, and answering "I
write the `result` field into the item" is right **for this driver** and fails on
any real bus. It is worth saying both halves together.
The reasoning to leave behind: the shared handle trick is not a
technique, it is a consequence of the driver being blocking. The condition is
written in the `get_next_item()`/`item_done()` of the previous slide — as long as the
`item_done()` is **after** having the response, there is a single item in flight and
the handle is enough. The day somebody moves that `item_done()` up to
gain throughput, the testbench keeps compiling and starts lying.
The other failure mode, more treacherous: a VIP that clones the item between the
sequence and the driver. There the driver writes into its copy, the sequence reads the
original, and the result that arrives is always the previous one. There is no error, there is no
warning: there is a scoreboard shifted by one.
And the `set_id_info()` detail, which is the one that makes this fail silently the
first time: if it is missing, the response is sent anyway and `get_response()` waits
forever. A test that "hangs after the first transaction" and uses REQ/RSP is this
bug until proven otherwise.


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
- And when there is **more than one sequencer**, the one that composes is a
  **virtual sequence**, which is first thing tomorrow ↪ day 7
- With **two sequences on the same sequencer** the one who hands out is the sequencer:
  priority and `set_arbitration(...)`, and `lock()`/`grab()` for the scenario that cannot
  be interleaved
- With this the testbench of the course is complete —it is missing one single
  piece, tomorrow's— and it is the way it is written today in the industry

Note:
Close of day 6. None of the pieces we did see is magic: we built them all by hand —the
observer of talking to several objects, the FIFO of put and get, the tester of
transactions— before UVM
handed them to us done. That is the reason the course goes in this order and does not start
with the `uvm_agent`.
And the best place to go on reading is `code/.uvm/src/`: by this point
`uvm_sequence_base.svh` can be opened and understood.
What is left for tomorrow is the **virtual sequence**, and it is left out of today
on purpose: it is only understood with this unit's testbench closed, and the
morning of day 7 is where the student looks at a new DUT and has to decide which
structure it deserves.
