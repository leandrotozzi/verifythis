<!-- es-sha: 9368389b7634 -->
## Agents

#### *The problem: a testbench that cannot be copied*

- The `env` we left in the transactions works, but it is a **welded block**:
  seven components and five `connect()` written by hand
- Every one of those components exists for a single reason: **it drives or
  watches the same interface**, the `vtalu_bfm`
- Ask what happens if the design brings *two* VTALU: you have to copy the seven
  objects, the five connections, and rename everything
- Copying and pasting structure is exactly what we had been avoiding since the `env`
- UVM puts a name on the solution: **`uvm_agent`**

![The env of transactions against the env with an agent](res/diagrams/en/agents_env_antes_despues.svg)
<!-- .element: class="grande" -->

Note:
The question that orders the whole section: what is the natural unit of reuse
in a testbench? It is not the component, and it is not the env. It is **the interface**.
Everything that knows how to speak one protocol gets packed together, and that box gets
instantiated once for every interface of the design. That is the agent, and it is nothing more.
If the group comes from RTL, the analogy works on its own: the agent is to the testbench what
a parameterizable module is to RTL. Nobody instantiates a FIFO by copying its
registers one at a time.

---

## Agents

#### *What is inside an agent*

- A `uvm_agent` is one more `uvm_component`: same tree, same phases, same
  factory
- What changes is **what it puts inside**, always the same:
  - a *sequencer*, which hands out stimulus
  - a *driver*, which turns it into signals of the BFM
  - the *monitors*, which watch the bus and publish transactions
- And it exposes outwards **two `uvm_analysis_port`**: the one that publishes commands and
  the one that publishes results
- The scoreboard and the coverage **do not go inside**: they are analysis, and they live in the
  `env` hanging off those two ports
- From this section on every piece uses **its** base class: `uvm_driver #(T)`,
  `uvm_sequencer #(T)` and `uvm_monitor` instead of a plain `uvm_component`

![Internal structure of the agent](res/diagrams/en/agents_agent.svg)
<!-- .element: class="grande" -->

Note:
There is a decision here that is worth saying out loud because the *UVM Primer* takes
it the other way round: it puts the scoreboard and the coverage *inside* the agent. We do not.
The reason is practical: the day you put a passive agent on an interface that
somebody else drives, you do not want a second scoreboard thrown in for free. The agent is
the **protocol** layer; the analysis belongs to the env, which is the one that knows what is being
verified.
The other reason is that if the scoreboard lives inside, the two analysis ports that
the agent exposes have nobody to serve, and half the design ends up decorative.
About the last bullet, because somebody is going to open `code/u7/agents` and see it:
up to the transactions the monitors extended `uvm_component`; from here on they extend
`uvm_monitor`. And `uvm_monitor` **does not add a single line of behaviour** — it is
`uvm_component` under another name. What it adds is intent: anybody who opens
the testbench knows what that class does without reading it, and `print_topology()` shows it
as a monitor.
It is the same economy as `uvm_env`: half the value of UVM is not in the
code of the library, it is in everybody using the same names for the same
things. `uvm_driver` and `uvm_sequencer` do bring things —the `seq_item_port` and the
arbitration—; `uvm_monitor`, `uvm_env` and `uvm_agent` are almost pure vocabulary.

---

## Agents

#### *The jump: from the tester to the sequence*

- In the put and get ports we split the stimulus in two: the `tester` chose **what**
  to send, the `driver` knew **how**
- We joined them with `uvm_put_port` / `uvm_get_port` and a `uvm_tlm_fifo` in the
  middle: three components in the tree and two `connect()`
- UVM already brings that done, and with a name: the **`uvm_sequencer`**
- The `driver` stops being a generic `uvm_component` and becomes
  `uvm_driver #(T)`, which **already comes with a `seq_item_port`**
- And the `tester` disappears: a `uvm_sequence` replaces it, and that **is not a
  component** — it is an object, it is not in the tree and it does not get connected

![From the put/get to the seq_item_port](res/diagrams/en/agents_seq_item_port.svg)
<!-- .element: class="grande" -->

Note:
This is the hardest jump of the course, and the reason is that there are two changes on
the same line. It is worth separating them.
Change one, structural: the FIFO is called a sequencer and comes with the driver.
Change two, conceptual: the stimulus generator **stops being a component**.
A component is built once in `build_phase` and lives the whole simulation;
a sequence is created, runs, finishes and gets thrown away — and you can run another one
right after on the same sequencer. That is what lets a test
combine stimuli without touching the structure, and that is what the sequences
section is all about.
The question to throw at the group: why does the driver of the passive agent not exist,
but the monitor does? Because driving is optional, watching is not.

---

## Agents

#### *The handshake: `get_next_item()` / `item_done()`*

- The driver no longer does `get()`: it does `get_next_item()`, which **blocks** until
  the sequence has something
- When it has finished driving the signals, it calls `item_done()`
- That second call is what the `put`/`get` pair **did not have**: it is the driver
  saying *"that is it, send me the next one"*
- Without `item_done()` the sequence hangs forever in its `finish_item()`, and
  the simulation stops advancing without a single error message
- The pair always goes complete, and in that order

{{code:code/u7/agents/tb_classes/driver.svh#run_phase}}

Note:
Forgetting `item_done()` is mistake number one of the first week, and the
symptom is misleading: no error, no warning, the simulation simply
stops advancing in time and the objection never gets dropped. Verilator has no
timeout by default: it keeps spinning until you kill it.
The trick to remember it: `get_next_item` / `item_done` is a **loan**, not
a copy. The sequence lends you the item and waits for you to
give it back. `put`/`get` was a delivery: the tester dropped the command and moved on.
And out of that comes the other useful difference: since the sequence still holds the
handle, the driver can write the result inside it and the sequence reads it when it
comes back from `finish_item()`. The sequences section uses that.

---

## Agents

#### *The driver, now a `uvm_driver`*

- `uvm_driver #(command_transaction)` brings the `seq_item_port` for free: it is not
  declared nor instantiated with `new()`
- The `build_phase` no longer looks for the BFM straight in the `config_db`: it asks the
  **agent config** for it
- The `run_phase` is **three lines**: ask for the item, `bfm.send_op(...)`, say
  it is done. The driver does not touch a wire
- The protocol stays where we left it in interfaces and BFM: **inside the BFM**. That is
  why the driver of an agent is so short, and why changing protocol does not
  touch it

{{code:code/u7/agents/tb_classes/driver.svh}}

Note:
It is worth opening the driver of the put and get ports alongside and counting lines: they are almost
the same. The only thing that changed is where the item comes from —before a `uvm_get_port`,
now the `seq_item_port`— and that there is an `item_done()` at the end.
The question worth asking: why is the driver so short? Because the protocol
is not here. It is in the BFM since interfaces and BFM, and this class only translates
*transaction* into *call*. That is the division of labour that makes an AXI
agent have the same twenty-line driver.
And the corollary, which is the one from the bus appendix: when the protocol changes,
the BFM and the monitor change. The driver, the agent, the env and the test never find out.

---

## Agents

#### *The sequencer gets declared with a `typedef`*

- `uvm_sequencer` is a parameterized class: it is parameterized with the type of item
  it is going to hand out
- There is no need to extend it for anything: it is used as is
- A `typedef` in the package gives it a short name, and that name is the one used by
  the agent and the `create()`

```systemverilog
typedef uvm_sequencer #(command_transaction) sequencer;
```

- The `command_transaction` of the transactions already extends `uvm_sequence_item`, so
  **it does not have to be touched**: that is why we chose that base class and not
  `uvm_transaction`
- The `typedef` goes **after** the `` `include `` of the transaction and **before**
  the driver and the agent

Note:
This is the moment when the decision from the transactions gets cashed in. If that day the
transaction had extended `uvm_transaction`, today this `typedef` would not compile:
`uvm_sequencer #(T)` requires that `T` derive from `uvm_sequence_item`.
It is worth saying explicitly: it is the first time in the course that a decision from
an earlier section enables —or breaks— the next one. That is exactly what
"adaptable code" means and it is not a phrase out of a manual.
And in case somebody tries it: extending `uvm_sequencer` to add things to it is
almost always a sign that it belonged in the sequence. The sequencer is an arbiter, not
a place to put logic.

---

## Agents

#### *The minimal sequence*

- A `uvm_sequence #(T)` has a task `body()`: that is all there is to
  write
- Every item goes between `start_item()` and `finish_item()`
- `start_item()` blocks until the sequencer gives us the turn; `finish_item()`
  blocks until the driver called `item_done()`
- The `randomize()` goes **between the two**: that way the constraints get resolved at
  the moment the item is about to be handed over, not before
- This is the direct translation of the `tester` of the transactions, and nothing more than
  that — the sequences section is about what can be done in here

{{code:code/u7/agents/tb_classes/command_sequence.svh#class-and-body}}

Note:
Two things worth marking in the code, because they are the ones that get copied wrong.
First: the transaction comes out of `type_id::create()`, the reset one and the
directed multiplication one too. It is the same rule as the transactions —the factory
only finds out about what goes through `create()`— and here it matters again because the
`add_test` is still around.
Second: `randomize()` between `start_item` and `finish_item` is not a whim of
style. Randomizing before works just the same today, but it breaks the day a constraint
depends on the state of the DUT or on the previous response: by then the value
had already been chosen. Randomizing late is the correct habit and it costs nothing
to adopt it from day one.

---

## Agents

#### *`is_active`: active and passive*

- `uvm_agent` brings a field `is_active` of type `uvm_active_passive_enum`, with
  two values: `UVM_ACTIVE` and `UVM_PASSIVE`
- **Active**: the sequencer and the driver get built. The agent drives the
  interface
- **Passive**: they do not get built. The agent **only watches** an interface that somebody
  else drives
- The monitors and the two analysis ports get built **always**: a passive
  agent keeps feeding scoreboard and coverage
- It is read with `get_is_active()` and decided in the `build_phase`, with an `if`

![Active against passive](res/diagrams/en/agents_active_passive.svg)
<!-- .element: class="grande" -->

Note:
The honest question is "and what do I want an agent that drives nothing for?". Three
answers from the field, in order of frequency:
One, output interfaces. A port the DUT drives and you only verify does not
need a driver, and the passive agent gives you the monitor and the coverage for free.
Two, integration. When the block you verified becomes part of a
chip, the interface stops being yours: the block next door drives it. The same
agent, with one different line in the config, still works. That is the real
return on having built an agent.
Three, the one from the example: living with stimulus that is not yours — a legacy module,
a reference model, a generator from another team.

---

## Agents

#### *And it can be seen*

- `bash run.sh +TOPOLOGY` prints the tree of components UVM built

```
      clase_agent_h          vtalu_agent
        command_ap           uvm_analysis_port
        command_monitor_h    command_monitor
        driver_h             driver
          seq_item_port      uvm_seq_item_pull_port
        result_ap            uvm_analysis_port
        result_monitor_h     result_monitor
        sequencer_h          uvm_sequencer
          seq_item_export    uvm_seq_item_pull_imp
      modulo_agent_h         vtalu_agent
        command_ap           uvm_analysis_port
        command_monitor_h    command_monitor
        result_ap            uvm_analysis_port
        result_monitor_h     result_monitor
```

- Same class, two instances, and one has four components fewer
- There too are the `seq_item_port` and the `seq_item_export` that the driver and the
  sequencer bring already fitted, without anybody declaring them — against the put and get ports,
  where the `uvm_put_port` had to be declared and `new()`ed
- `print_topology()` is besides the debug tool for when a `connect()`
  points at a component that does not exist

Note:
This tree is printed by the library, not by the course, and that is the whole point: up to here
the hierarchy was a diagram on a slide, and now it is an output you can
grep. It is worth running it live — it is the `print_topology()` of the reporting
section, now with something worth looking at.
The two things to make them see, side by side: `clase_agent_h`
has `driver_h` and `sequencer_h`, and `modulo_agent_h` does **not**. That is
`is_active` in practice — the same class type, instantiated twice, and one
built two objects fewer. Both monitors are in both, because watching
is never optional.
And the one that is not there: there is no `sequence` in this tree. A sequence is a
`uvm_object`, not a `uvm_component`, so it does not live in the topology. It is the
question thrown out on day 3 with the class diagram, and here it can be answered
pointing at the screen.

---

## Agents

#### *The config object of the agent*

- The agent needs two pieces of data from outside: **which BFM** and **whether it is active**
- Both travel together in a configuration object, which is the public interface
  of the agent
- It is a **bare class**, not a `uvm_object`: that is why the constructor can
  **demand** both pieces of data, and whoever forgets one does not compile
- A `uvm_object` is created with `type_id::create()`, which only takes a `name`: the
  guarantee of the constructor is lost
- The field `is_active` goes `protected` with a getter: nobody changes it after
  the agent has been built

{{code:code/u7/agents/tb_classes/vtalu_agent_config.svh}}

Note:
Here the course departs from the custom of the industry on purpose, and it is worth
saying so: most projects do `class agent_config extends uvm_object`
and register it in the factory, so it can be overridden. It is a legitimate decision and
it has its reason. The downside is the one in the bullet: you lose the constructor
that forces you.
What is not negotiable is the underlying idea, and it is the one to leave behind: **every
level of hierarchy receives its configuration through an object**. If a component
needs five pieces of data, that is not five `uvm_config_db::get()` scattered around: it is
a config. The day you add the sixth piece of data, you touch one class and not six.
Notice that the driver and the two monitors also ask for the config, not the BFM: the
agent does not hand out handles by hand.

---

## Agents

#### *The agent class: `build_phase`*

- It asks the `uvm_config_db` for its config and copies the `is_active` **by hand**:
  without `super.build_phase()`, `uvm_agent`'s, the one that would read it, never runs
- It builds sequencer and driver **only if it is active**; the monitors and the two
  analysis ports, always
- The analysis ports are ports: they get instantiated with `new()`, not with the factory

{{code:code/u7/agents/tb_classes/vtalu_agent.svh#class-and-build}}

Note:
A detail worth gold that nobody tells: the `build_phase` of `uvm_agent` that
the library brings **only reads `is_active` from the resource pool**. It is in
`code/.uvm/src/comps/uvm_agent.svh`, it can be opened in class.
Which means that in a testbench that calls `super.build_phase()`, a
`uvm_config_db#(int)::set(this, "mi_agent", "is_active", UVM_PASSIVE)` works
on its own, without a config object. Since this `vtalu_agent` does not call it,
that mechanism **is switched off**, and that is why we assign it by hand.
And here is where day 3 gets paid: `uvm_agent` and `uvm_sequencer` are the two
classes in the library that do real work in their `build_phase` —`uvm_agent` reads
`is_active`, and `uvm_sequencer_param_base` hooks up the response fifo
(`seq/uvm_sequencer_param_base.svh:288`)—. It is exactly the case the rule for out
there covers: if you extend either of the two and you write a `build_phase`, the
`super` is mandatory. You inherited from an intermediate class that does real
work, and skipping the `super` switches it off without a word. We can
skip it because we wrote the line that replaces it; whoever does not write that
line, cannot.
Both ways are valid. What is not valid is half of each one: putting
`is_active` in the config_db, not calling `super.build_phase()`, and then
wondering why the agent starts up active. It happens often.

---

## Agents

#### *The agent class: `connect_phase`*

- Inside: the `seq_item_port` of the driver against the `seq_item_export` of the
  sequencer — **a single line**, and only if it is active
- Outwards: the `ap` of each monitor gets connected to the analysis port **of the
  agent**
- That second `connect()` is the one that makes the agent a closed box: the
  `env` never touches `command_monitor_h`, it talks to `command_ap`
- The mantra *ports connect to exports* still holds, with one more twist: a
  port also connects **to another port of the same type, outwards**. That is
  `command_monitor_h.ap.connect(command_ap)`, and it is called *port forwarding*

Note:
*Port forwarding* is what confuses, and it is worth saying why it exists before
how it is written. The agent wants to offer outwards a piece of data produced by a child
of its own. It could expose the child —the `env` looking at `agent.command_monitor_h.ap`— and
that is where the encapsulation ends: the day the monitor changes name, the
`env` breaks.
The way out is for the agent to have **its own** analysis port and plug it into the
monitor's. From outside a single port is seen, `command_ap`, and inside there can be
whatever. It is exactly what a module does when it connects a port of its own to that of
a submodule — the same idea, with classes.
The detail that looks like it breaks the mantra: here a **port connects to another port**, not
to an export. It is not a capricious exception — the direction is still the same,
from the one who calls to the one who implements; the only thing that happens is that the agent is in
the middle and implements nothing, it only forwards.

---

## Agents

#### *How the `env` ends up*

- Four lines of structure instead of seven objects and five connections
- The `env` no longer knows there is a driver, or a sequencer, or a FIFO: it knows
  there is an agent and that it has two analysis ports
- The scoreboard and the coverage stay just as in the analysis ports: they are
  subscribers, and they find out about nothing

{{code:code/u7/agents/env_un_agent.svh#class-and-build}}

- That is the `env` of a single VTALU. With two, it changes less than it looks

Note:
This is the slide for making the comparison live: open the `env.svh` of transactions
alongside. The difference is not that it is shorter —which it also is—, it is **what
disappeared**: the `env` of transactions named `command_f`, which means it knew the
internal mechanism of how the stimulus reached the driver. This one does not name
it. That is encapsulation measured objectively: count the names that
the class above has to know.
If the group is doing well on time, the question is worth it: what would have to
change in this `env` to go from a FIFO to a sequencer? Nothing. It is already
inside the agent.

---

## Agents

#### *Two agents, one single string*

- The two agents execute **the same line**:
  `uvm_config_db#(vtalu_agent_config)::get(this, "", "config", cfg)`
- And yet they have to receive **different objects**
- The second argument of the `set()` resolves it: the **scope**, which is the path
  of the component that is going to read
- `"clase_agent_h*"` reaches that agent and everything hanging off it — that is why
  the driver and the monitors find the same config without anybody passing it to them
- The `this` of the `set()` is the starting point of that path: the `env`

![The hierarchical scope of the config_db](res/diagrams/en/agents_config_scope.svg)
<!-- .element: class="grande" -->

Note:
Here is the classic trap of the section, and it is one of the ones that never fail. With a single
agent, everybody writes `"*"` in the scope and it works. The day the
second one shows up, the second `set()` overwrites the first and **both agents get the
same config**: the same BFM and the same `is_active`. With the order in `env.svh` —the
class first and the module after— the one left standing is the passive one, so both
start up passive, with no driver and no sequencer, and the test's `seq.start()` lands
on a `null` handle. With the order reversed they would be two drivers, but driving
**the same** interface. What is invariant, and what to take away: the last `set()`
wins, and both agents end up identical. The error does not show up in `build_phase`.
The asterisk matters: `"clase_agent_h*"` with an asterisk reaches the children;
`"clase_agent_h"` without an asterisk, only the agent. If you write it without an asterisk, the
agent finds its config and the driver does not — `uvm_fatal` in `build_phase`, which at
least is an honest error.
Short rule to take away: **the scope of the `set()` is a path, not a label.**

---

## Agents

#### *When the `config_db` does not find: `+UVM_CONFIG_DB_TRACE`*

```sh
$ bash run.sh +UVM_CONFIG_DB_TRACE
UVM_INFO ... Configuration 'config' (type vtalu_agent_config) set by env_h
UVM_INFO ... Configuration 'config' read by
             accessor=uvm_test_top.env_h.clase_agent_h.driver_h
UVM_INFO ... Configuration 'config' read by
             accessor=uvm_test_top.env_h.modulo_agent_h.command_monitor_h
```

- The `config_db` is a database by strings: when it fails, **it fails in
  silence** or with a `uvm_fatal` that does not say why
- `+UVM_CONFIG_DB_TRACE` makes UVM print **every `set()` and every `get()`**,
  with the complete hierarchical path of the component that asked for it
- It works for the two questions one asks: *did the `set()` reach this
  component?* and *which components actually exist?*
- It is a plusarg, not code: nothing has to be touched or recompiled

Note:
This is the tool that tests was missing, when we said that
`get(null, "*", ...)` "does not fail: it lies". With the trace on, lying becomes
difficult: you see who put what and who read it.
The use almost nobody discovers on their own is the second one: **since every `get()` prints the
path of the component that called it, the output is a census of the tree written by the
library.** If a component does not show up, it was not built. The exercise of the day
uses exactly that to grade itself, and that is why it cannot be cheated: the
student does not write those lines.
A close relative worth naming: `+UVM_OBJECTION_TRACE`, for the other classic
hang —the simulation that does not finish because somebody did not drop their objection—.

---

## Agents

#### *The example: two VTALU and the legacy module*

- The case that justifies all of this: two **sources of stimulus** have to be compared
  on the same design
- The `top` instantiates two VTALU and two `vtalu_bfm`
- The first one is driven by our agent, in `UVM_ACTIVE`
- The second one is driven by `vtalu_tester_module`, an ordinary module without one line
  of UVM, and we hang an agent on it in `UVM_PASSIVE` to watch it
- Two scoreboards and **two coverages**: that is what answers which of the two
  stimuli covers more

{{code:code/u7/agents/top.sv#top}}

- The module calls **the very same `bfm.send_op()`** as the driver: it receives the
  interface through its **port** instead of through a virtual interface, but the
  protocol it executes is exactly the same code
- That is what makes the comparison fair: both stimuli speak identically to
  the DUT. The only thing being compared is **what** each one sends, not how

Note:
This `top.sv` is the one that closes the argument of the section, and it is worth reading
looking for what did **not** change: there are two VTALU, two interfaces, two different
`config_db`, and the `vtalu_tester_module` is still the same old Verilog module
as always. Nobody touched it so it could live with UVM.
That is the real scenario the section comes to solve, and it is worth naming it like this:
you arrive at a project where there is already a stimulus written in Verilog that works and
nobody is going to rewrite. With a passive agent you can **watch** it —scoreboard,
coverage, assertions— without asking anybody's permission or touching a line of it.
The technical detail that makes the comparison fair, and that has to be pointed at with a
finger: the module calls the same `bfm.send_op()` as the driver. It receives the
interface through a port instead of through a virtual interface, but the protocol is the
same code. If each one drove the bus its own way, comparing coverages would
not mean anything.

---

## Agents

#### *The test, and what is still missing*

- The `test` takes the two BFM out of the `config_db`, builds the `env_config` and passes it down
- Then it starts the sequence **by hand**, on the sequencer of the active agent:

```systemverilog
seq = command_sequence::type_id::create("seq");
seq.start(env_h.clase_agent_h.sequencer_h);
```

- It works, but look at what that line does: the test **goes across the hierarchy**
  to reach the sequencer, and with that it knows the inside of the env again
- Everything we have just encapsulated leaks out in one line
- The sequences section fixes it: the sequence is handed to the sequencer **through the
  `config_db`**, and the test stops knowing where it is

{{code:code/u7/agents/tb_classes/dual_test.svh#build-and-run}}

Note:
This is the slide to close the day with if there is no time for the
summary: it leaves an open question and a concrete promise.
And it is honest: `seq.start(env_h.clase_agent_h.sequencer_h)` is real code that
works and that is seen in many testbenches. It is not "wrong". It is simply the
last thing in the testbench that is still hard-wired, and it is the one the section
that follows knocks over.
If somebody asks why we do not do it right from the start: because to understand the
`default_sequence` you first have to have suffered writing the `start()` by hand.

---

## Agents

#### *What this section does differently*

- **The book does not use a sequencer here.** In *The UVM Primer* the agent of this
  section still has the `tester` and the `uvm_tlm_fifo` inside, and the sequencer
  only shows up with sequences — where besides the `tester` disappears
- We build the agent **complete in one go**: it is the way it is written
  today, and it makes the sequences section be only about sequences
- **The scoreboard and the coverage stay outside the agent**, against what
  the *UVM Primer* does. A passive agent should not drag a scoreboard along
- **The config of the agent is not a `uvm_object`**: it is a bare class, so that
  the constructor forces you. The industry usually makes it a `uvm_object`
- The protocol lives in the BFM, the same as in the *UVM Primer*. Up to Verilator 5.051 this
  could not be done: an interface task called through a virtual interface did not
  propagate. It was fixed in 5.052 — `docs/verilator.md`

Note:
That the material says where it departs from its sources is not a detail of
tidiness: it is what lets the student read the *UVM Primer* afterwards without
believing that one of the two is broken.
And along the way it leaves the lesson most used at work: the structure of a
UVM testbench is not fixed by the standard, it is fixed by custom. IEEE 1800.2 does not say
anywhere that the scoreboard goes in the env. It says what a `uvm_agent` is and
nothing else. Everything else is convention — good, but convention.

---

## Agents

#### *Summary of the unit*

- An **agent** packs everything that knows how to speak one interface: sequencer,
  driver and monitors, wired inside a single time
- It gets instantiated **once per interface**, and it is configured with a **configuration
  object**, not with loose handles
- **`is_active`** decides whether, besides watching, it drives
- The `env` went from seven components wired by hand to **one agent and two
  subscribers**
- The `uvm_config_db` stops being a global mailbox: the **scope** is a path in
  the tree, and with more than one agent it is what makes each one receive its own
- One single thing was left hard-wired: the test still looks for the sequencer by hand to
  start the sequence. **That is the sequences section**

Note:
Close of the section and of the biggest jump of the course. It is worth saying where they ended up
standing: with today's material, the student can read the testbench of any
UVM project and recognise the structure. An agent per interface, a config per level, analysis
in the env. It is literally 80 % of what they will see on their first day.
What is missing —sequences— is what they will *write* on their first day. That is why they go
together on the same day and in this order: first the house, then what happens
inside.
