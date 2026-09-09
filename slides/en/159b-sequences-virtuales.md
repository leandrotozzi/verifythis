<!-- es-sha: a692208e3f2e -->
## Virtual sequences

#### *The problem: two interfaces and a single `start()`*

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
First hour of day 7, and that is on purpose. It is the last piece of the reusable
testbench, and it arrives on capstone day because it is the day the student looks
at a new DUT and decides which structure it deserves. The capstone has **two**
APB slaves, each with its own interface —one driven by the testbench, the other
by a module— and that is the shape of the agents section: one active and one
passive, a single sequencer, and no virtual sequence. This hour is what gives the
student the criterion to decide that instead of guessing it, and what leaves them
the answer written down for the day the second slave is theirs too.
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

## Virtual sequences

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

## Virtual sequences

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

## Virtual sequences

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
And the criterion for the afternoon: in the capstone the second slave is driven
by a module, so there is **one** sequencer and this is not needed. The virtual
sequence comes in the day both interfaces belong to the testbench and one depends
on the other — and then it is written just like here.

---

## Virtual sequences

#### *And if branch B has to wait for A?*

```systemverilog
// uvm_event: a notice, from one to many. It comes from the global pool, nobody builds it
uvm_event listo = uvm_event_pool::get_global("dut_configurado");

listo.trigger();          // the branch that configured gives notice
listo.wait_trigger();     // the one waiting blocks here
listo.wait_ptrigger();    // the same, but if it already happened, it walks on

// uvm_barrier: a meeting point between N branches
uvm_barrier arranque = uvm_barrier_pool::get_global("arranque");
arranque.set_threshold(2);
arranque.wait_for();      // neither of the two goes on until both have arrived
```

- The `join` synchronizes **at the end**. When branch B has to wait for A
  **in the middle**, a synchronization object is needed
- `uvm_event` is **one to many**: one gives notice, those waiting move on. And
  `trigger(data)` can carry a `uvm_object` attached
- `uvm_barrier` is **symmetric**: nobody goes on until everybody has arrived. It is the
  "start together" of two agents that have to begin on the same cycle
- A shared `bit` with `wait(flag)` is not enough: it **loses the pulse** if the one
  waiting arrived late, and it carries no data

Note:
This is the question that shows up on its own as soon as the `fork` of the previous
slide is drawn, and it is worth answering right there: *"and if branch B cannot start
until A configured the DUT?"*.
The distinction to make clear is **one to many versus symmetric**. The
`uvm_event` has a side that gives notice and another that waits, and the roles do not
change: it is for "the reset finished", "the DUT is configured", "the interrupt
arrived". The `uvm_barrier` has no sides: the N branches execute the same
line and none goes on until all are there. It is for "start together" and for
"everybody wait until the configuration phase ends".
The `wait_ptrigger()` deserves its own second, because it is the classic race: if
branch A triggers before B reaches the `wait_trigger()`, B waits
forever. The `p` is for *persistent*: it asks whether the event **already** happened at some point.
The practical rule: if you cannot guarantee the order, `wait_ptrigger()`.
And why not a shared `bit`, which is the first thing anybody tries: a `bit` does not
keep history, does not carry attached data, and cannot be reset between phases without
somebody swallowing a pulse. The two UVM objects exist precisely because
that homemade version fails once every hundred runs.
Its own failure mode: a barrier with the threshold set wrong does not give an error —
it hangs. The symptom is a test that ends on `+UVM_TIMEOUT` without a single
`UVM_ERROR`, and `+UVM_OBJECTION_TRACE` shows the objection up and nobody
moving on.
