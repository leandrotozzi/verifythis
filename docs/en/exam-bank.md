<!-- Generado por tools/build.mjs desde slides/*quiz*.md. NO editar a mano:
     la pregunta se corrige en la slide y esto se regenera con `npm run build`.
     `npm run check` falla si quedo viejo. -->

# Exam bank

The **45 review questions** of the course, without the answer
marked — which is the only thing that separates an in-class review from an exam. They come from
the same `slides/*quiz*.md` as the deck, so there are never two versions of one
question.

The **key is at the end**, with the reason for each one: it is what you need
in order to grade without going back to look for the slide.

How to use it, and what to assess in each midterm: **[`para-docentes.md`](../para-docentes.md)** (in Spanish).

> The course is **CC BY 4.0**: it can be printed, cut up, reordered and given as
> your own exam. The only thing asked is that you cite the source.

---

## Day 1 · 6 questions

**1. Trends**

According to the Wilson 2024 study, where does most of a verifier's time go?

- **a)** Into writing the testbench
- **b)** Into debug
- **c)** Into running regressions
- **d)** Into writing the specification

**2. The ALU spec**

While the VTALU is running an operation, what do `start` and the operands have to do?

- **a)** `start` drops right away; the operands can change
- **b)** It makes no difference: the DUT registers them on the first edge
- **c)** The operands have to change on every cycle
- **d)** `start` stays at 1 and the operands stable until `done` goes up

**3. Functional coverage**

The test runs 1000 random operations and the *code* coverage reads 100 %. What does that tell you about the verification?

- **a)** That the DUT is verified
- **b)** Very little: it says which RTL got **executed**, not which scenarios of the **spec** happened
- **c)** That the testbench has no bugs
- **d)** That the verification plan can already be closed

**4. covergroup**

You declare a `covergroup`, you `new()` it, you run a thousand operations and the report reads 0 %. What is the first thing to look at?

- **a)** That the bins are badly defined
- **b)** That nobody is calling `sample()`
- **c)** That the DUT is not answering
- **d)** That `ignore_bins` are missing

**5. Interfaces and BFM**

What does the testbench gain when the protocol moves into a BFM?

- **a)** The rest of the TB stops talking in signals and starts talking in operations
- **b)** It simulates faster
- **c)** The testbench becomes synthesizable
- **d)** You save having to declare a `clk`

**6. clocking block**

Are clocking blocks needed to write a UVM testbench without races?

- **a)** Yes: without a clocking block, driver and DUT always compete on the same edge
- **b)** Yes, and they are also part of the UVM library
- **c)** No: NBA in the driver plus scheduler discipline is enough — they are an optional abstraction, useful above all in reusable agents
- **d)** No, and that is why they should never be used

---

## Day 2 · 8 questions

**7. Handle and object**

`rectangle rectangle_h;` — after that line, how many objects are there?

- **a)** None: `rectangle_h` is `null` until somebody calls `new()`
- **b)** One, with `length` and `width` at 0
- **c)** One, half built
- **d)** It depends on whether the class has a constructor

**8. Polymorphism**

A variable of type `trago` holds a `fernet` object. If `servir()` is not `virtual`, what gets executed?

- **a)** `fernet`'s `servir()`
- **b)** A compile error
- **c)** `trago`'s `servir()`
- **d)** Both, the base class one first

**9. Abstract classes**

What do I gain by using an abstract class with `pure virtual` methods instead of a base class whose method does `$fatal`?

- **a)** Nothing, it is a matter of style
- **b)** That the error moves from simulation to the compiler
- **c)** That the base class can be instantiated
- **d)** That the methods run faster

**10. Static variables**

I instantiate 10 objects of a class that has a `static` variable. How many copies are there in memory?

- **a)** 10, one per object
- **b)** 0 until somebody writes it
- **c)** 1, shared by every instance
- **d)** It depends on the simulator

**11. Static methods**

Why is it worth declaring the static variable `protected` and exposing it with static methods?

- **a)** To be able to change the data structure without touching whoever uses it
- **b)** Because otherwise it does not compile
- **c)** So that it takes up less memory
- **d)** Because UVM demands it

**12. Parameterized classes**

`bandeja#(fernet)` and `bandeja#(mojito)` have a `static` queue inside. Do they share the queue?

- **a)** Yes, `static` is a single one for everybody
- **b)** Yes, unless it is declared `protected`
- **c)** It depends on whether they get instantiated or not
- **d)** No: each specialization of the parameter is a different class, with its own queue

**13. The factory pattern**

What problem does the factory pattern solve?

- **a)** Creating objects faster
- **b)** Deciding at run time which subtype to build, without hardcoding the `new`
- **c)** Avoiding having to declare classes
- **d)** Copying objects without sharing the handle

**14. $cast**

When does a `$cast(destination, source)` succeed?

- **a)** Always: it converts any class into any other
- **b)** Only between classes with no inheritance
- **c)** Only at compile time
- **d)** Only if the object in `source` really is of the class of `destination` or of a derived one

---

## Day 3 · 7 questions

**15. `uvm_test`**

What does `+UVM_TESTNAME=add_test` let you do that you could not do before?

- **a)** Pick the test on an already compiled testbench, without recompiling
- **b)** Run the simulation faster
- **c)** Change the DUT without recompiling
- **d)** Lower the verbosity of the messages

**16. UVM Phases**

In what order does UVM walk the hierarchy in `build_phase` and in `connect_phase`?

- **a)** Both from the top down
- **b)** Both from the bottom up
- **c)** `build_phase` top-down, `connect_phase` bottom-up
- **d)** In the order the components were declared

**17. Objections**

What are `raise_objection()` / `drop_objection()` for in the `run_phase`?

- **a)** For reporting scoreboard errors
- **b)** For keeping the simulation alive while the component has work
- **c)** For synchronizing two threads
- **d)** For registering the class in the factory

**18. The env**

What does each one get: `uvm_env` and `uvm_test`?

- **a)** `env` generates the stimulus; `test` assembles the structure
- **b)** Both do the same thing, `env` is optional
- **c)** `env` runs the DUT; `test` runs the scoreboard
- **d)** `env` assembles the structure of the TB; `test` defines which stimulus gets applied

**19. Factory override**

`set_type_override()` replaces `base_tester` with `add_tester`. When does it have to be called?

- **a)** Before the `build_phase` that creates the object runs
- **b)** At any moment: the factory applies it retroactively
- **c)** After the `connect_phase`
- **d)** Inside the `run_phase` of the tester

**20. Verbosity**

The verbosity ceiling (`+UVM_VERBOSITY=UVM_HIGH`), which macros does it act on?

- **a)** On all four: info, warning, error and fatal
- **b)** Only on `` `uvm_info ``
- **c)** On error and fatal only
- **d)** On none: it only changes the format of the message

**21. Report actions**

You want to silence the `` `uvm_error `` of a scoreboard somebody else is fixing. Where does the `set_report_severity_action_hier()` go?

- **a)** In the `build_phase` of the `env`
- **b)** In the `run_phase` of the test
- **c)** In the constructor of the scoreboard
- **d)** In the `end_of_elaboration_phase` of the `env`

---

## Day 4 · 5 questions

**22. Observer Pattern**

In the Observer pattern, what does the observed object know about its observers?

- **a)** How many there are and of what type
- **b)** Only the first one that subscribed
- **c)** It knows them because they get handed to it in the constructor
- **d)** Nothing: not how many there are, not who they are, not what they do with the data

**23. Analysis Ports**

A `uvm_subscriber` needs data from two different analysis ports. How does that get solved?

- **a)** By implementing the `write()` method twice
- **b)** With a `uvm_tlm_analysis_fifo` for the second port
- **c)** By registering the component twice in the factory, once per port
- **d)** By connecting both ports to the same `analysis_export`

**24. Intra vs. inter thread**

When the monitor publishes and the `write()`s of the subscribers run, how many threads are involved?

- **a)** One per subscriber
- **b)** Two: the publisher's and the subscriber's
- **c)** Only one: it is **intra**-thread communication, they are function calls
- **d)** It depends on how many subscribers there are

**25. Put and get ports**

The consumer calls `get()` and the `uvm_tlm_fifo` is empty. What happens?

- **a)** It blocks until the producer puts a piece of data in
- **b)** It returns 0 and carries on
- **c)** A UVM fatal error
- **d)** It returns the last piece of data read

**26. try_get()**

And `try_get()` with the FIFO empty?

- **a)** It blocks just like `get()`
- **b)** It returns 1 with a garbage value
- **c)** It returns 0 immediately, without blocking
- **d)** It waits one clock cycle and tries again

---

## Day 5 · 4 questions

**27. Deep copy**

`obj1_h = obj2_h`. What did I copy?

- **a)** Nothing: both handles point at the same object
- **b)** Every field of `obj2_h` into `obj1_h`
- **c)** Only the `rand` fields
- **d)** A shallow copy of the first level

**28. super.do_copy()**

Why does every `do_copy()` of the hierarchy have to call `super.do_copy()`?

- **a)** Because UVM requires it in order to register the class
- **b)** So that the object ends up registered in the factory
- **c)** Because otherwise the fields of the classes above do not get copied
- **d)** In order to be able to randomize after copying

**29. clone()**

`clone()` returns a `uvm_object`. Why is it recommended to write a `clone_me()` as well?

- **a)** To wrap the `$cast` up in a single place and not repeat it all over the TB
- **b)** Because `clone()` does not copy the data
- **c)** Because `clone()` is deprecated in IEEE 1800.2
- **d)** In order to be able to clone components as well as transactions

**30. Constrained Random**

`A dist {8'h00 := 1, [8'h01:8'hFE] := 1, 8'hFF := 1};` — how often does `A = 8'h00` come up?

- **a)** A third of the time: they are three entries with the same weight
- **b)** Half: the edges share it between the two of them
- **c)** One time in 256: with `:=` the weight is applied to **each value** of the range
- **d)** Never: `:=` only accepts single values, not ranges

---

## Day 6 · 10 questions

**31. is_active**

An agent in `UVM_PASSIVE`, what does its `build_phase` build?

- **a)** Nothing: a passive agent is an empty shell
- **b)** Everything the same as an active one, but without connecting the driver to the sequencer
- **c)** The monitors and the analysis ports; the sequencer and the driver are left at `null`
- **d)** Only the sequencer, so it can receive sequences from another agent

**32. The handshake of the driver**

The driver calls `get_next_item()`, drives the signals and forgets the `item_done()`. What happens?

- **a)** Compilation error: UVM demands the complete pair
- **b)** The sequencer hands over the next item just the same, with a warning
- **c)** The item gets discarded and the scoreboard reports a mismatch
- **d)** The sequence stays waiting in `finish_item()` and the simulation does not advance any more

**33. Scope of the config_db**

The `env` instantiates two agents and does both `set()` with the scope `"*"`. What does each one receive?

- **a)** Both fail with `uvm_fatal`: the string `"config"` is duplicated
- **b)** Each one receives its own, in order of creation
- **c)** Both receive the same object: the second `set()` overwrites the first
- **d)** The first receives its config and the second is left with `cfg == null`

**34. The sequencer**

`typedef uvm_sequencer #(command_transaction) sequencer;` compiles without touching the transaction of the transactions. Why?

- **a)** Because it is registered in the factory with `` `uvm_object_utils ``
- **b)** Because `uvm_sequencer` accepts any `uvm_object`
- **c)** Because the driver does the `$cast` internally
- **d)** Because `command_transaction` extends `uvm_sequence_item`

**35. super.build_phase()**

Instead of the config object, you put `is_active` straight into the `uvm_config_db`. In this course the agent starts up active all the same. Why?

- **a)** Because `is_active` is `protected` and the `config_db` cannot write it
- **b)** Because the `config_db` does not accept enumerated types
- **c)** Because `is_active` is fixed in the constructor and `build_phase` arrives late
- **d)** Because the one who reads it is the `build_phase` of `uvm_agent`, and `vtalu_agent` does not call `super.build_phase()`

**36. Object, not component**

What is the practical difference of a `uvm_sequence` being a `uvm_object` and not a `uvm_component`?

- **a)** That it cannot be registered in the factory nor overridden
- **b)** That it gets created, runs and is thrown away: you can start several, one after the other, on the same sequencer
- **c)** That it cannot have `rand` fields nor constraints
- **d)** That it starts on its own when the simulation begins, without anybody calling it

**37. start_item()**

`start_item(command)` has just come back. What is it that this guarantees?

- **a)** That the driver has already received the item and is driving the signals
- **b)** That the sequencer gave the turn to this sequence: nobody else is going to beat it to the driver
- **c)** That the `randomize()` has already been resolved with the constraints of the class
- **d)** That the objection of the phase is already raised

**38. The way back**

At what moment does `command.result` have a value that can be read?

- **a)** As soon as `start_item()` came back
- **b)** When the `result_monitor` publishes it through its analysis port
- **c)** When `finish_item()` came back, because the driver wrote it before calling `item_done()`
- **d)** Never: to receive a response you have to use the REQ/RSP pair of `uvm_sequence #(REQ, RSP)`

**39. default_sequence**

You configure a `default_sequence` through `uvm_config_db` and forget the `set_automatic_phase_objection(1)`. What happens?

- **a)** `uvm_fatal` in `build_phase`: the sequence does not find the sequencer
- **b)** It runs just the same: when there is a `default_sequence`, the sequencer raises the objection
- **c)** The `main_phase` finishes at t=0 and the test passes with 0 errors without having sent a single piece of stimulus
- **d)** The simulation hangs waiting for an objection nobody drops

**40. Sub-sequences**

`full_sequence` starts its daughters with `reset_seq.start(get_sequencer(), this)`. What is the second argument for?

- **a)** To pass it the sequencer, because `get_sequencer()` only returns the type
- **b)** To declare the daughter a sub-sequence of the mother: it inherits her turn and her priority in the arbitration
- **c)** So the daughter runs in a separate thread, in parallel with the mother
- **d)** To register the daughter in the factory under the name of the mother

---

## Day 7 · 5 questions

**41. Immediate and concurrent**

What is the underlying difference between `assert(x.randomize())` and `assert property (@(posedge clk) …)`?

- **a)** None: the second is syntactic sugar for the first
- **b)** The first can be switched off from the command line and the second cannot
- **c)** The first is a **statement** that runs when the thread goes past it; the second is a **declaration with a clock** that gets evaluated on every edge, on its own
- **d)** The first is only valid inside a class and the second only inside a module

**42. `|->` against `|=>`**

The `done` of the VTALU comes out of an `always_ff`. Which implication goes in `start |?? done`?

- **a)** `|->`, because the antecedent and the consequent belong to the same transaction
- **b)** `|=>`, because what gets written with `<=` on edge *n* is only read on *n+1*
- **c)** Either of the two: the difference is a matter of style
- **d)** Neither: for registered signals you have to use `$past()`

**43. The sampling edge**

All the properties of the VTALU sampled on `@(posedge clk)` give 185 errors over 1000 operations, and the DUT is healthy. Why?

- **a)** The `disable iff (!reset_n)` is missing
- **b)** The `posedge` is too fast: the clock has to be divided
- **c)** The BFM writes the stimulus **on the `negedge`**, and on two consecutive `no_op` `start` goes down and comes back up between two `posedge`: the sampling does not see it go down
- **d)** Covergroups and assertions cannot share the same clock

**44. The assertion that checks nothing**

An `assert` property reports 0 failures during the whole regression. What do you know?

- **a)** That the rule it describes holds
- **b)** That the DUT is free of protocol bugs
- **c)** Nothing yet: its antecedent may never have occurred, or `--assert` may be missing and it is not even being evaluated
- **d)** That the property has a badly written `disable iff`

**45. Assertion or scoreboard**

The DUT gives back the right `result` but drops `done` one cycle earlier than the specification says. Who catches it?

- **a)** The scoreboard, when it compares the result
- **b)** The functional coverage, because the `done` bin is left empty
- **c)** An assertion in the interface: it is a **protocol** bug, and the monitor has already erased the time before the transaction reaches the scoreboard
- **d)** The `uvm_fatal` of the `command_monitor`, which would stop seeing commands

---

## Key

| # | Day | Topic | Correct | Why |
|--:|:--:|:--|:--:|:--|
| 1 | 1 | Trends | **b** | **Into debug** — 47 % of the verifier's time goes there. That is why the course devotes a whole section to reporting: a scoreboard that only says "failed" leaves you right inside that 47 %. |
| 2 | 1 | The ALU spec | **d** | **Stable until `done`** — it is the DUT protocol, and it is exactly the reason the BFM exists: to wrap that rule in a single place so that no test forgets it. |
| 3 | 1 | Functional coverage | **b** | **Very little** — code coverage measures the DUT; functional coverage measures the spec. A feature the designer never wrote gives 100 % of lines and 0 % of what matters, and the report is not going to tell you. |
| 4 | 1 | covergroup | **b** | **The `sample()`** — a covergroup does not sample itself: somebody has to call it, on the edge or when a transaction arrives. Without that call the code compiles, runs, and the report reads 0 without a single warning. |
| 5 | 1 | Interfaces and BFM | **a** | **It stops talking in signals** — the BFM translates *one operation* into *a handshake of signals*. The tester, the scoreboard and the coverage never touch a wire again: it is the first step towards UVM. |
| 6 | 1 | clocking block | **c** | **They are not needed, and they are worth using anyway** — they belong to **SystemVerilog**, not to UVM. What avoids the race is understanding the scheduler: a driver that drives with `<=` against a DUT that registers with `<=` is already deterministic. The clocking block does not replace that understanding, it **wraps** it — and that is where it pays off: reusable agents, VIP, gate-level and protocols with setup/hold in the spec. |
| 7 | 2 | Handle and object | **a** | **None** — declaring a handle reserves nothing. There is the difference with a `struct`, which the simulator reserves the moment it sees it. And using the handle before the `new()` does not fail at compile time: it blows up in the middle of the simulation. |
| 8 | 2 | Polymorphism | **c** | **`trago`'s** — without `virtual`, SystemVerilog looks at the **type of the variable**, not at the object's. It is literally what `code/u3/polimorfismo/01-sin-virtual` prints: *"A generic trago cannot be served"*. |
| 9 | 2 | Abstract classes | **b** | **The error moves to the compiler** — with `$fatal` you find out halfway through the simulation that an override was missing. With `pure virtual` it does not compile. Catching it earlier is always cheaper. |
| 10 | 2 | Static variables | **c** | **A single one** — and it exists even if you instantiate no object at all. That is what makes it useful for global TB data, and what makes it dangerous if you leave it public. |
| 11 | 2 | Static methods | **a** | **To be able to change it later** — if the queue is out in the open, the day you swap it for another structure you have to go and fix every place that touched it. Encapsulating is being able to change your mind. |
| 12 | 2 | Parameterized classes | **d** | **They do not share it** — SystemVerilog generates **one class per combination of parameters**. `static` is unique inside each one of those classes, not across all of them. UVM leans on this all the time. |
| 13 | 2 | The factory pattern | **b** | **Deciding the subtype at runtime** — you ask the factory for an object and it decides which one. It is the piece that is later going to let you change the stimulus of a whole test without touching the code of the `env`. |
| 14 | 2 | $cast | **d** | **Only if the object allows it** — `$cast` checks **at runtime** and returns 0 if it does not work. That is why UVM's factory is more comfortable than the animals example: it returns the right type and saves you the cast. |
| 15 | 3 | `uvm_test` | **a** | **Pick the test without recompiling** — UVM reads that plusarg and asks the **factory** for the test by name. It is the difference between 1000 tests × 5 minutes of compilation and a single compilation. |
| 16 | 3 | UVM Phases | **c** | **Build top-down, connect bottom-up** — and it makes sense: you cannot connect a component that does not exist yet, so first the whole hierarchy gets built and only then does it get connected. |
| 17 | 3 | Objections | **b** | **So that the phase does not end early** — every `run_phase` runs in parallel, each one in its thread, and the phase ends when **the last objection drops**. Without raising it, the simulation ends on you at time 0. |
| 18 | 3 | The env | **d** | **Structure vs. stimulus** — each class does **one single thing well**. That is why the `env` almost always has only `build_phase` and `connect_phase`, and the test almost always has only a factory override. |
| 19 | 3 | Factory override | **a** | **Before the `build_phase`** — the factory decides what to build **at the moment of the `create()`**. If the override arrives late, the `env` has already instantiated the base class and it does nothing. |
| 20 | 3 | Verbosity | **b** | **Only on `` `uvm_info ``** — warnings, errors and fatals are **immune** to the verbosity ceiling, and it is right that they should be: nobody wants to switch off an error by accident. For those you need the *actions* mechanism. |
| 21 | 3 | Report actions | **d** | **In `end_of_elaboration_phase`** — it has to be **after** the hierarchy is built (otherwise the component does not exist yet) and **before** the simulation starts. That phase is exactly that window. |
| 22 | 4 | Observer Pattern | **d** | **It knows nothing** — and that ignorance is the whole point. Adding a fourth subscriber does not force you to touch one line of the one publishing. |
| 23 | 4 | Analysis Ports | **b** | **With a `uvm_tlm_analysis_fifo`** — a `uvm_subscriber` has a single `write()`, so it can only listen to one port. The FIFO gives an `analysis_export` on one side and a `try_get()` on the other. It is what the VTALU scoreboard does. |
| 24 | 4 | Intra vs. inter thread | **c** | **Only one** — `write()` is a `function`, not a `task`: it consumes no time and runs in the thread of the one publishing. That is precisely why **another** mechanism (put/get + FIFO) is needed to talk between threads. |
| 25 | 4 | Put and get ports | **a** | **It blocks** — `get()` is blocking, and that is why it is declared `task` and not `function`. That is the whole synchronization: no hand-written signal handshake is needed. |
| 26 | 4 | try_get() | **c** | **It returns 0 and carries on** — it is the non-blocking version, and that is why it can be a `function`. Notice that the scoreboard uses it in a `do ... while` to skip over the `no_op`s and the `rst_op`s. |
| 27 | 5 | Deep copy | **a** | **Nothing** — there is no copy, there is a second name for the same object. If you modify it through one handle, the other sees it. That is where the *MOOCOW* rule comes from: if you are going to modify, copy first. |
| 28 | 5 | super.do_copy() | **c** | **Otherwise the fields from above get lost** — it is the same problem as `convert2string()`: the day somebody puts a new level in the middle, the method stops seeing half the data and nobody warns you. |
| 29 | 5 | clone() | **a** | **So as not to repeat the `$cast`** — without it, every place that clones ends up writing its own cast. It is the same old idea: if you are going to repeat it, wrap it up. |
| 30 | 5 | Constrained Random | **c** | **1 in 256** — `:=` gives weight 1 to *each one* of the 254 values in the middle, so the range weighs 254 against 1 and 1 from the edges. To share the weight out *inside* the range you use `:/`. Both forms compile and run: the difference only shows up in the coverage that does not go up. |
| 31 | 6 | is_active | **c** | **The monitors, always** — watching is never optional: a passive agent goes on feeding scoreboard and coverage. What gets skipped is what *drives* the interface, because there somebody else is already driving it. |
| 32 | 6 | The handshake of the driver | **d** | **It hangs, and without saying anything** — it is the classic mistake of the first week, and the symptom misleads: there is no error and no warning, time stops advancing and the objection never gets dropped. `get_next_item()` is a loan; `item_done()` is giving it back. |
| 33 | 6 | Scope of the config_db | **c** | **Both receive the same thing** — the `uvm_config_db` does not match by order nor by type: it matches by **path**. With `"*"` both entries describe the same components, so the last one wins. The scope is a path in the tree, not a label. |
| 34 | 6 | The sequencer | **d** | **Because of the base class we chose in transactions** — `uvm_sequencer #(T)` requires that `T` derive from `uvm_sequence_item`. If that day the transaction had extended a plain `uvm_transaction`, this `typedef` would not compile today. A decision of one section enabling the next. |
| 35 | 6 | super.build_phase() | **d** | **That mechanism is switched off** — `uvm_agent::build_phase` looks for `is_active` in the resource pool (it is in `code/.uvm/src/comps/uvm_agent.svh`, it can be opened). Without `super.build_phase()` that line never runs, and nobody warns you. Both ways are valid; what does not work is half of each one. |
| 36 | 6 | Object, not component | **b** | **It gets created, runs and is thrown away** — a component is built once in `build_phase` and lives to the end. That is why the stimulus cannot be a component: it changes from test to test, and sometimes within the same test. Out of that comes as well that it can be configured between the `create()` and the `start()`, the way `full_seq.count = 200` does. |
| 37 | 6 | start_item() | **b** | **You have the turn, you have not handed anything over yet** — and that is why the `randomize()` goes *after*: it is the last possible moment to choose the values, when you already know what state the DUT is in. That is late randomization, and it is where `pre_do()` and `mid_do()` hook on. |
| 38 | 6 | The way back | **c** | **After `finish_item()`** — there is no way back at all: there is a shared handle and an agreement between the two parties. The REQ/RSP pair exists and is the formal mechanism, but almost nobody uses it: writing the result into the request is enough. This is what makes Fibonacci possible. |
| 39 | 6 | default_sequence | **c** | **It passes in zero seconds, and it lies** — a phase without an objection finishes as soon as it starts. It is the same kind of bug as the `new()` that eats the override: it does not break, it deceives. And in a regression of a thousand tests, the one that passes in zero seconds is one nobody looks at. |
| 40 | 6 | Sub-sequences | **b** | **It declares the mother-daughter relationship** — without it, the sequencer treats the two as independent sequences and they compete for the turn. With it, the daughter inherits the context. And for the parallel that is not enough: a `fork` / `join` around the `start()` is needed. |
| 41 | 7 | Immediate and concurrent | **c** | **Statement against declaration** — the immediate one is to an `if` what the concurrent one is to an `always_ff`: one executes, the other gets instantiated. That is why only the concurrent one can describe something that lasts several cycles. |
| 42 | 7 | `\|->` against `\|=>` | **b** | **`\|=>` when the consequent comes out of a `<=`** — and the operational rule is to look at the RTL, not at the property: if the consequent comes out of an `assign`, it takes `\|->`. Getting this wrong almost never gives an error: it gives a property that always passes. |
| 43 | 7 | The sampling edge | **c** | **An assertion is worth what its sampling is worth** — the stimulus gets sampled where the stimulus gets written. Stimulus on `negedge`, response of the DUT on `posedge`: zero errors. With a single clock there is no way. |
| 44 | 7 | The assertion that checks nothing | **c** | **Zero failures and zero evaluations look the same** — that is why every assertion goes with its `cover property`: it is the only check of the check. In the section, `c_mult_3ciclos` stays at 0 and gives away that the real latency is four edges, not three. |
| 45 | 7 | Assertion or scoreboard | **c** | **Protocol → assertion. Data → scoreboard** — and it is not a preference: by the time the transaction reaches the scoreboard, the protocol is no longer there. Writing the check there would be rebuilding by hand the time the monitor has just erased. |
