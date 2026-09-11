<!-- Generado por tools/build.mjs desde slides/*quiz*.md. NO editar a mano:
     la pregunta se corrige en la slide y esto se regenera con `npm run build`.
     `npm run check` falla si quedo viejo. -->

# Exam bank

The **58 review questions** of the course, without the answer
marked — which is the only thing that separates an in-class review from an exam. They come from
the same `slides/*quiz*.md` as the deck, so there are never two versions of one
question.

The **key is at the end**, with the reason for each one: it is what you need
in order to grade without going back to look for the slide.

How to use it, and what to assess in each midterm: **[`for-teachers.md`](for-teachers.md)**.

> The course is **CC BY 4.0**: it can be printed, cut up, reordered and given as
> your own exam. The only thing asked is that you cite the source.

---

## Day 1 · 7 questions

**1. The question of the day**

A thousand random operations, the scoreboard reported no error and the log ends in `PASS`. What are you missing to say the DUT is verified?

- **a)** Nothing: a thousand operations without an error is a verified DUT
- **b)** Running more seeds until code coverage reaches 100 %
- **c)** Knowing what the log would have said with a bug inside: run it with the mutated DUT
- **d)** Replacing the scoreboard with assertions, which check the protocol on the exact edge and not at the end

**2. The ALU spec**

While the VTALU is running an operation, what do `start` and the operands have to do?

- **a)** `start` drops right away: it is a start pulse, and the DUT already latched everything
- **b)** It makes no difference: the DUT registers them on the first edge
- **c)** The operands have to change on every cycle
- **d)** `start` at 1 and the operands still until `done` goes up

**3. Functional coverage**

The test runs 1000 random operations and the *code* coverage reads 100 %. What does that tell you about the verification?

- **a)** That the DUT is verified and the verification plan can be closed
- **b)** That the testbench has no bugs
- **c)** That few scenarios are missing: 100 % already walked the whole design
- **d)** Very little: it measures the RTL that ran, not the spec

**4. covergroup**

You declare a `covergroup`, you `new()` it, you run a thousand operations and the report reads 0 %. What is the first thing to look at?

- **a)** That nobody is calling `sample()`
- **b)** That the bins are badly defined and match no value at all
- **c)** That the DUT is not answering
- **d)** That `ignore_bins` are missing

**5. Interfaces and BFM**

What does the testbench gain when the protocol moves into a BFM?

- **a)** It stops talking in signals and starts talking in operations
- **b)** It simulates faster: one BFM task costs the simulator less than moving wires
- **c)** The testbench becomes synthesizable
- **d)** You save having to declare a `clk`

**6. The verification plan**

In the verification plan, what goes in the *Measure* column?

- **a)** How long the scenario takes to run, so the regression can be estimated
- **b)** The name of the testbench file that covers that row
- **c)** Which bin gets filled when the scenario happens
- **d)** How many times the test has to be run to call it covered

**7. clocking block**

Are clocking blocks needed to write a UVM testbench without races?

- **a)** Yes: without a clocking block, driver and DUT always compete on the same edge
- **b)** Yes, and they are also part of the UVM library
- **c)** No: NBA in the driver plus scheduler discipline is enough
- **d)** No: the `uvm_driver` replaces them, since it already samples in the right region

---

## Day 2 · 8 questions

**8. Handle and object**

`rectangle rectangle_h;` — after that line, how many objects are there?

- **a)** None: `rectangle_h` is `null` until somebody calls `new()`
- **b)** One, with `length` and `width` at 0
- **c)** One half built: the fields exist but the constructor has not run
- **d)** It depends on whether the class has a constructor

**9. Polymorphism**

A variable of type `trago` holds a `fernet` object. If `servir()` is not `virtual`, what gets executed?

- **a)** `fernet`'s `servir()`
- **b)** A compile error
- **c)** `trago`'s `servir()`
- **d)** Both, the base class one first

**10. Abstract classes**

What do I gain by using an abstract class with `pure virtual` methods instead of a base class whose method does `$fatal`?

- **a)** Nothing, it is a matter of style
- **b)** That the error moves from simulation to the compiler
- **c)** That the base class can be instantiated
- **d)** That the simulator can pick the most specific override at run time

**11. Static variables**

I instantiate 10 objects of a class that has a `static` variable. How many copies are there in memory?

- **a)** 10, one per object
- **b)** 0 until somebody writes it: the memory is reserved on first access
- **c)** 1, shared by every instance
- **d)** It depends on the simulator

**12. Static methods**

Why is it worth declaring the static variable `protected` and exposing it with static methods?

- **a)** To be able to change the data structure without touching whoever uses it
- **b)** Because a `static` without `protected` is reserved once per instance
- **c)** So that it takes up less memory
- **d)** Because UVM demands it

**13. Parameterized classes**

`bandeja#(fernet)` and `bandeja#(mojito)` have a `static` queue inside. Do they share the queue?

- **a)** Yes, `static` is a single one for everybody
- **b)** Yes: the parameter changes the type of the methods, not the static storage
- **c)** It depends on whether they get instantiated or not
- **d)** No: each specialization is a different class, with its own queue

**14. The factory pattern**

What problem does the factory pattern solve?

- **a)** Creating objects faster
- **b)** Deciding at run time which subtype to build
- **c)** Avoiding having to declare classes
- **d)** Centralizing the `new()`s in one class, to be able to count and free them

**15. $cast**

When does a `$cast(destination, source)` succeed?

- **a)** Always: it converts any class into any other
- **b)** Only between classes with no inheritance
- **c)** When the two classes have the same fields, even if they are not related
- **d)** Only if the object in `source` is of the class of `destination` or of a derived one

---

## Day 3 · 7 questions

**16. `uvm_test`**

What does `+UVM_TESTNAME=add_test` let you do that you could not do before?

- **a)** Pick the test on an already compiled testbench
- **b)** Run the simulation faster
- **c)** Change the DUT without recompiling: UVM re-elaborates on start-up
- **d)** Lower the verbosity of the messages

**17. UVM Phases**

In what order does UVM walk the hierarchy in `build_phase` and in `connect_phase`?

- **a)** Both from the top down
- **b)** Both from the bottom up
- **c)** `build_phase` top-down, `connect_phase` bottom-up
- **d)** In the order the components were declared, from the top down

**18. Objections**

What are `raise_objection()` / `drop_objection()` for in the `run_phase`?

- **a)** For reporting scoreboard errors
- **b)** For keeping the simulation alive while there is work
- **c)** For synchronizing two threads
- **d)** So that the `run_phase`s of every component start at the same time

**19. The env**

What does each one get: `uvm_env` and `uvm_test`?

- **a)** `env` generates the stimulus; `test` assembles the structure
- **b)** Both do the same thing, `env` is optional
- **c)** `env` runs the DUT; `test` runs the scoreboard
- **d)** `env` assembles the structure; `test` picks the stimulus

**20. Factory override**

`set_type_override()` replaces `base_tester` with `add_tester`. When does it have to be called?

- **a)** Before the `build_phase` that creates the object runs
- **b)** At any moment: the factory applies it retroactively to what is already built
- **c)** After the `connect_phase`
- **d)** Inside the `run_phase` of the tester

**21. Verbosity**

The verbosity ceiling (`+UVM_VERBOSITY=UVM_HIGH`), which macros does it act on?

- **a)** On all four: info, warning, error and fatal
- **b)** Only on `` `uvm_info ``
- **c)** On error and fatal only
- **d)** On none: it only changes the format of the message

**22. Report actions**

You want to silence the `` `uvm_error `` of a scoreboard somebody else is fixing. Where does the `set_report_severity_action_hier()` go?

- **a)** In the `build_phase` of the `env`
- **b)** In the `run_phase` of the test, before raising the objection
- **c)** In the constructor of the scoreboard
- **d)** In the `end_of_elaboration_phase` of the `env`

---

## Day 4 · 5 questions

**23. Observer Pattern**

In the Observer pattern, what does the observed object know about its observers?

- **a)** How many there are and of what type
- **b)** Only the first one that subscribed
- **c)** It knows them because they get handed to it in the constructor, one by one
- **d)** Nothing: not how many there are, not who they are

**24. Analysis Ports**

A `uvm_subscriber` needs data from two different analysis ports. How does that get solved?

- **a)** By implementing the `write()` method twice
- **b)** With a `uvm_tlm_analysis_fifo` for the second port
- **c)** By registering the component twice in the factory, once per port
- **d)** By connecting both ports to the same `analysis_export`

**25. Intra vs. inter thread**

When the monitor publishes and the `write()`s of the subscribers run, how many threads are involved?

- **a)** One per subscriber
- **b)** Two: the publisher's and the subscriber's
- **c)** Only one: `write()` is a function call
- **d)** One per subscriber plus the monitor's, and UVM syncs them at the end of the delta

**26. Put and get ports**

The consumer calls `get()` and the `uvm_tlm_fifo` is empty. What happens?

- **a)** It blocks until the producer puts a piece of data in
- **b)** It returns 0 and carries on
- **c)** A UVM fatal error
- **d)** It returns the last piece of data read, which stays in the FIFO until overwritten

**27. try_get()**

And `try_get()` with the FIFO empty?

- **a)** It blocks just like `get()`
- **b)** It returns 1 with a garbage value
- **c)** It waits one clock cycle and tries again, up to the timeout of the phase
- **d)** It returns 0 immediately, without blocking

---

## Day 5 · 8 questions

**28. Deep copy**

`obj1_h = obj2_h`. What did I copy?

- **a)** Nothing: both handles point at the same object
- **b)** Every field of `obj2_h` into `obj1_h`
- **c)** Only the `rand` fields
- **d)** A shallow copy: the first level is copied and the handles inside get shared

**29. super.do_copy()**

Why does every `do_copy()` in the hierarchy have to call `super.do_copy()`?

- **a)** Because UVM demands it in order to register the class
- **b)** So that the object ends up registered in the factory
- **c)** Because otherwise the fields of the classes above do not get copied
- **d)** Because `do_copy()` is `pure virtual` and the base class has no implementation

**30. clone()**

`clone()` returns a `uvm_object`. Why is it recommended to also write a `clone_me()`?

- **a)** To wrap the `$cast` in a single place
- **b)** Because `clone()` does not copy the data
- **c)** Because `clone()` is deprecated in IEEE 1800.2 and `copy()` replaces it
- **d)** To be able to clone components as well as transactions

**31. `dist`: `:=` against `:/`**

`A dist {8'h00 := 1, [8'h01:8'hFE] := 1, 8'hFF := 1};` — how often does `A = 8'h00` come out?

- **a)** A third of the time: they are three entries with the same weight
- **b)** Half: the edges share it between the two of them
- **c)** Never: `:=` only takes single values, not ranges, and the range is dropped
- **d)** Once every 256: with `:=` the weight goes to **each value**

**32. `randomize() with {}`**

`cmd.randomize() with { A == 8'hFF; }` — what happens to the constraints the class already had?

- **a)** They get replaced: for that call only what is inside the braces counts
- **b)** They add up: both have to be satisfied
- **c)** They stay switched off until the next `randomize()` without a `with`
- **d)** It depends on the declaration order: the one lower in the file wins

**33. constraint_mode()**

`randomize() with { A == 8'hFF; }` on a field the class spreads with a `dist` returns 0 three times out of four. What is the workaround?

- **a)** Retry in a `do ... while` until it returns 1
- **b)** `constraint_mode(0)` on the `dist` constraint, for that object
- **c)** Raise the weight of the `8'hFF` bin in the `dist` of the class
- **d)** `rand_mode(0)` on the field: it takes the `dist` out and lets the `with` rule

**34. rand_mode()**

What does `cmd.A.rand_mode(0)` do?

- **a)** It switches off every constraint that mentions that field
- **b)** It randomizes it once and freezes it afterwards
- **c)** It makes the solver resolve it last, after all the other fields
- **d)** It takes the field out of the draw and leaves it the value it had

**35. The order of resolution**

`rand bit es_reset; rand byte unsigned A;` with `constraint c { es_reset -> A == 8'h00; }`. How often does `es_reset = 1` come out?

- **a)** Half the time: it is a `rand` bit and nothing forbids it
- **b)** Never: the implication forces it to 0
- **c)** 1 in 257: the solver draws among the **solutions**
- **d)** It depends on the seed, and over enough runs it averages out to half

---

## Day 6 · 10 questions

**36. is_active**

An agent in `UVM_PASSIVE`, what does its `build_phase` build?

- **a)** The monitors and the analysis ports; the driver and the sequencer, no
- **b)** Nothing: a passive agent is an empty shell
- **c)** Everything the same as an active one, but without connecting the driver to the sequencer
- **d)** Only the sequencer, so it can receive sequences from another agent of the same env

**37. The handshake of the driver**

The driver calls `get_next_item()`, drives the signals and forgets the `item_done()`. What happens?

- **a)** Compilation error: UVM demands the complete pair
- **b)** The sequencer hands over the next item just the same, with a warning
- **c)** The item gets discarded and the scoreboard reports a mismatch on the next comparison
- **d)** The sequence stays waiting in `finish_item()` and does not advance any more

**38. Scope of the config_db**

The `env` instantiates two agents and does both `set()` with the scope `"*"`. What does each one receive?

- **a)** Both fail with `uvm_fatal`: the string `"config"` is duplicated
- **b)** Each one receives its own, in order of creation
- **c)** Both receive the same one: the second `set()` overwrites the first
- **d)** The first receives its config and the second is left with `cfg == null`

**39. The sequencer**

`typedef uvm_sequencer #(command_transaction) sequencer;` compiles without touching the transaction of the transactions. Why?

- **a)** Because it is registered in the factory with `` `uvm_object_utils ``
- **b)** Because `uvm_sequencer` accepts any `uvm_object`
- **c)** Because the driver does the `$cast` internally
- **d)** Because `command_transaction` extends `uvm_sequence_item`

**40. super.build_phase()**

Instead of the config object, you put `is_active` straight into the `uvm_config_db`. In this course the agent starts up active all the same. Why?

- **a)** Because `is_active` is `protected` and the `config_db` cannot write it
- **b)** Because the `config_db` does not accept enumerated types, only `int` and `string`
- **c)** Because `is_active` is fixed in the constructor and `build_phase` arrives late
- **d)** Because the one who reads it is `uvm_agent::build_phase`, and nobody calls `super`

**41. Object, not component**

What is the practical difference of a `uvm_sequence` being a `uvm_object` and not a `uvm_component`?

- **a)** That it gets created, runs and is thrown away
- **b)** That it cannot be registered in the factory nor overridden
- **c)** That it cannot have `rand` fields nor constraints
- **d)** That UVM builds it in `build_phase`, like any other class of the tree

**42. start_item()**

`start_item(command)` has just come back. What is it that this guarantees?

- **a)** That the driver has already received the item and is driving the signals
- **b)** That the sequencer gave the turn to this sequence
- **c)** That the `randomize()` has already been resolved with the constraints of the class
- **d)** That the objection of the phase is already raised by the sequencer

**43. The way back**

At what moment does `command.result` have a value that can be read?

- **a)** When `finish_item()` came back, because the driver wrote it before calling `item_done()`
- **b)** As soon as `start_item()` came back
- **c)** When the `result_monitor` publishes it through its analysis port
- **d)** Never: to receive a response you have to use the REQ/RSP pair of `uvm_sequence #(REQ, RSP)`

**44. default_sequence**

You configure a `default_sequence` through `uvm_config_db` and forget the `set_automatic_phase_objection(1)`. What happens?

- **a)** `uvm_fatal` in `build_phase`: the sequence does not find the sequencer
- **b)** It runs just the same: when there is a `default_sequence`, the sequencer raises the objection on its own
- **c)** The `main_phase` finishes at t=0 and the test passes with 0 errors
- **d)** The simulation hangs waiting for an objection nobody drops

**45. Sub-sequences**

`full_sequence` starts its daughters with `reset_seq.start(get_sequencer(), this)`. What is the second argument for?

- **a)** To pass it the sequencer, because `get_sequencer()` only returns the type
- **b)** To declare the daughter a sub-sequence of the mother
- **c)** So the daughter runs in a separate thread, in parallel with the mother
- **d)** To register the daughter in the factory under the name of the mother, so it can be overridden

---

## Day 7 · 5 questions

**46. Immediate and concurrent**

What is the underlying difference between `assert(x.randomize())` and `assert property (@(posedge clk) …)`?

- **a)** One is a **statement**; the other, a **declaration with a clock**
- **b)** None: the second is syntactic sugar for the first
- **c)** The first can be switched off from the command line and the second cannot
- **d)** The first is only valid inside a class and the second only inside a module, because of the scheduler

**47. `|->` against `|=>`**

The `done` of the VTALU comes out of an `always_ff`. Which implication goes in `start |?? done`?

- **a)** `|->`, because the antecedent and the consequent belong to the same transaction
- **b)** `|=>`, because what gets written with `<=` is read one edge later
- **c)** Either of the two: the difference is a matter of style
- **d)** Neither: for registered signals you have to use `$past()` on the antecedent

**48. The sampling edge**

All the properties of the VTALU sampled on `@(posedge clk)` give 145 errors over 1000 operations, and the DUT is healthy. Why?

- **a)** The `disable iff (!reset_n)` is missing
- **b)** The `posedge` is too fast: the clock has to be divided
- **c)** Covergroups and assertions cannot share the clock without a `clocking block`
- **d)** The stimulus is written on the `negedge` and the sampling does not see it

**49. The assertion that checks nothing**

An `assert` property reports 0 failures during the whole regression. What do you know?

- **a)** Nothing yet: it may never have been evaluated at all
- **b)** That the rule it describes holds
- **c)** That the DUT is free of protocol bugs
- **d)** That the property has a badly written `disable iff` and stayed off the whole time

**50. Assertion or scoreboard**

The DUT gives back the right `result` but drops `done` one cycle earlier than the specification says. Who catches it?

- **a)** The scoreboard, when it compares the result
- **b)** The functional coverage, because the `done` bin is left empty
- **c)** An assertion in the interface: it is a **protocol** bug
- **d)** The `uvm_fatal` of the `command_monitor`, which would stop seeing commands on the bus

---

## Day 8 · 8 questions

**51. The access string**

`CLR` clears itself when you write a 1 to it. You declare it `"WOC"`, and `bit_bash` and `mirror(UVM_CHECK)` give zero errors. What happened?

- **a)** Nothing: `WOC` is the access that describes a field that clears on a write
- **b)** `WOC` is not in the LRM, so UVM treats it as a plain `RW`
- **c)** Both skip `WO*` accesses: that bit never got tested
- **d)** The predictor leaves the mirror at `x`, and a comparison against `x` always passes

**52. Automatic or explicit prediction**

What changes between `set_auto_predict(1)` and hooking a `uvm_reg_predictor` to the monitor?

- **a)** With auto-predict the model believes what it **meant** to send, not what happened
- **b)** Nothing: the predictor is the internal implementation of auto-predict
- **c)** The predictor is faster: it does not build the bus transaction
- **d)** Auto-predict only works frontdoor, and the predictor works backdoor too

**53. volatile**

`STATUS` changes on its own, without anybody writing it. What are you saying when you declare it `volatile` in `configure()`?

- **a)** That the mirror is not evidence: the value can change without going through the bus
- **b)** That UVM is going to re-read it from the DUT before every comparison, to be safe
- **c)** That the field drops out of the map and stops having an address
- **d)** That it has to be read backdoor, because the frontdoor does not get there in time

**54. mirror() against read()**

`model.CTRL.read(status, data)` and `model.CTRL.mirror(status, UVM_CHECK)`. How do they differ?

- **a)** `read` goes over the bus and `mirror` stays in the mirror, with no transfer at all
- **b)** `mirror` writes the mirror into the DUT, to leave the two of them equal
- **c)** `read` updates the mirror and `mirror` does not touch it, so as not to hide an error
- **d)** Both read from the DUT; `mirror` also compares against what the model believed

**55. Who knows about the bus**

What does the `uvm_reg_block` know about the APB?

- **a)** The base address and the width of `PADDR`, which reach it through the `uvm_reg_map`
- **b)** Nothing: the only one that knows about the bus is the adapter
- **c)** Everything: that is why there is one register model per protocol
- **d)** The SETUP and ACCESS timing, to predict the wait state of the read

**56. DPI and time**

Can an `import "DPI-C" function` of the golden model wait for a clock edge?

- **a)** Yes, by putting a `#1` inside the `.c`
- **b)** No: a `function` runs in zero time
- **c)** Yes, as long as the `.c` is compiled with Verilator's timing support
- **d)** Yes: the simulator suspends the C thread for the duration of the call

**57. undefined reference**

The `.c` is written and it compiles, and the link fails with *undefined reference* to the golden model function. What do you look at first?

- **a)** Whether the DPI flag is missing from the `verilator` command line
- **b)** Whether the `.c` is in its own `-f` and not mixed in with the `.sv`
- **c)** The name, and the `extern "C"`: the symbol may have come out mangled
- **d)** Whether the SystemVerilog `function` is declared `virtual` so the symbol gets exported

**58. The scoreboard that never shouted**

The scoreboard with the golden model in C runs a thousand operations and reports not one. Is that enough?

- **a)** Yes: a thousand comparisons without a single difference is the definition of verified
- **b)** Yes, as long as the functional coverage closed at 100 % on top of that
- **c)** No, because both sides share the opcode `enum` and cancel each other out
- **d)** No: a scoreboard that has never seen an error is not tested

---

## Key

| # | Day | Topic | Correct | Why |
|--:|:--:|:--|:--:|:--|
| 1 | 1 | The question of the day | **c** | **Watch it fail** — the `PASS` of a scoreboard that never saw an error says nothing: it may not have compared. `VTALU_BUG=1` flips one bit of the result and the testbench has to fail; `make mutante` demands it for the three testbenches of days 1 and 2. |
| 2 | 1 | The ALU spec | **d** | **Stable until `done`** — it is the DUT protocol, and it is exactly the reason the BFM exists: to wrap that rule in a single place so that no test forgets it. The first distractor describes a real protocol —pulse start, latched operands— that this DUT does not have. |
| 3 | 1 | Functional coverage | **d** | **Very little** — code coverage measures the DUT; functional coverage measures the spec. A feature the designer never wrote gives 100 % of lines and 0 % of what matters, and the report is not going to tell you. |
| 4 | 1 | covergroup | **a** | **The `sample()`** — a covergroup does not sample itself: somebody has to call it, on the edge or when a transaction arrives. Without that call the code compiles, runs, and the report reads 0 without a single warning. |
| 5 | 1 | Interfaces and BFM | **a** | **It stops talking in signals** — the BFM translates *one operation* into *a handshake of signals*. The tester, the scoreboard and the coverage never touch a wire again: it is the first step towards UVM. |
| 6 | 1 | The verification plan | **c** | **Which bin gets filled** — the five columns are *Feature*, *Scenario*, *Stimulus*, *Check* and *Measure*, and this is the one that costs the most: it forces you to decide **beforehand** what is going to be counted. If it is left empty, nobody is going to find out that the scenario never happened — a case the random never touched and that has no bin is indistinguishable from one that happened a thousand times. |
| 7 | 1 | clocking block | **c** | **They are not needed, and they are worth using anyway** — they belong to **SystemVerilog**, not to UVM, and no `uvm_driver` samples for you. What avoids the race is understanding the scheduler: a driver that drives with `<=` against a DUT that registers with `<=` is already deterministic. The clocking block does not replace that understanding, it **wraps** it — and that is where it pays off: reusable agents, VIP, gate-level and protocols with setup/hold in the spec. |
| 8 | 2 | Handle and object | **a** | **None** — declaring a handle reserves nothing. There is the difference with a `struct`, which the simulator reserves the moment it sees it. And using the handle before the `new()` does not fail at compile time: it blows up in the middle of the simulation. |
| 9 | 2 | Polymorphism | **c** | **`trago`'s** — without `virtual`, SystemVerilog looks at the **type of the variable**, not at the object's. It is literally what `code/u3/polimorfismo/01-sin-virtual` prints: *"A generic trago cannot be served"*. |
| 10 | 2 | Abstract classes | **b** | **The error moves to the compiler** — with `$fatal` you find out halfway through the simulation that an override was missing. With `pure virtual` it does not compile. Catching it earlier is always cheaper. |
| 11 | 2 | Static variables | **c** | **A single one** — and it exists even if you instantiate no object at all. That is what makes it useful for global TB data, and what makes it dangerous if you leave it public. |
| 12 | 2 | Static methods | **a** | **To be able to change it later** — if the queue is out in the open, the day you swap it for another structure you have to go and fix every place that touched it. Encapsulating is being able to change your mind. |
| 13 | 2 | Parameterized classes | **d** | **They do not share it** — SystemVerilog generates **one class per combination of parameters**. `static` is unique inside each one of those classes, not across all of them. UVM leans on this all the time. |
| 14 | 2 | The factory pattern | **b** | **Deciding the subtype at runtime** — without hardcoding the `new`: you ask the factory for an object and it decides which one. It is the piece that is later going to let you change the stimulus of a whole test without touching the code of the `env`. |
| 15 | 2 | $cast | **d** | **Only if the object allows it** — `$cast` checks **at runtime** and returns 0 if it does not work. That is why UVM's factory is more comfortable than the `cantina` of the section: `type_id::create()` returns the right type and saves you the cast. |
| 16 | 3 | `uvm_test` | **a** | **Pick the test without recompiling** — UVM reads that plusarg and asks the **factory** for the test by name. It is the difference between 1000 tests × 5 minutes of compilation and a single compilation. |
| 17 | 3 | UVM Phases | **c** | **Build top-down, connect bottom-up** — and it makes sense: you cannot connect a component that does not exist yet, so first the whole hierarchy gets built and only then does it get connected. |
| 18 | 3 | Objections | **b** | **So that the phase does not end early** — every `run_phase` runs in parallel, each one in its thread, and the phase ends when **the last objection drops**. Without raising it, the simulation ends on you at time 0. |
| 19 | 3 | The env | **d** | **Structure vs. stimulus** — each class does **one single thing well**. That is why the `env` almost always has only `build_phase` and `connect_phase`, and the test almost always has only a factory override. |
| 20 | 3 | Factory override | **a** | **Before the `build_phase`** — the factory decides what to build **at the moment of the `create()`**. If the override arrives late, the `env` has already instantiated the base class and it does nothing. |
| 21 | 3 | Verbosity | **b** | **Only on `` `uvm_info ``** — warnings, errors and fatals are **immune** to the verbosity ceiling, and it is right that they should be: nobody wants to switch off an error by accident. For those you need the *actions* mechanism. |
| 22 | 3 | Report actions | **d** | **In `end_of_elaboration_phase`** — it has to be **after** the hierarchy is built (otherwise the component does not exist yet) and **before** the simulation starts. That phase is exactly that window. |
| 23 | 4 | Observer Pattern | **d** | **It knows nothing** — and that ignorance is the whole point. Adding a fourth subscriber does not force you to touch one line of the one publishing. |
| 24 | 4 | Analysis Ports | **b** | **With a `uvm_tlm_analysis_fifo`** — a `uvm_subscriber` has a single `write()`, so it can only listen to one port. The FIFO gives an `analysis_export` on one side and a `try_get()` on the other. It is what the VTALU scoreboard does. The other way is `` `uvm_analysis_imp_decl ``, which manufactures one `write_` per suffix: they are not two `write()` in the same class, which SystemVerilog does not allow. |
| 25 | 4 | Intra vs. inter thread | **c** | **Only one, and it is intra-thread communication** — `write()` is a `function`, not a `task`: it consumes no time and runs in the thread of the one publishing. That is precisely why **another** mechanism (put/get + FIFO) is needed to talk between threads. |
| 26 | 4 | Put and get ports | **a** | **It blocks** — `get()` is blocking, and that is why it is declared `task` and not `function`. That is the whole synchronization: no hand-written signal handshake is needed. |
| 27 | 4 | try_get() | **d** | **It returns 0 and carries on** — it is the non-blocking version, and that is why it can be a `function`. Notice that the scoreboard uses it in a `do ... while` to skip over the `no_op`s and the `rst_op`s. |
| 28 | 5 | Deep copy | **a** | **Nothing** — there is no copy, there is a second name for the same object. If you modify it through one handle, the other one sees it. Out of that comes the *MOOCOW* rule: if you are going to modify, copy first. |
| 29 | 5 | super.do_copy() | **c** | **Otherwise the fields above get lost** — it is the same problem as `convert2string()`: the day somebody puts a new level in the middle, the method stops seeing half the data and nobody warns you. |
| 30 | 5 | clone() | **a** | **So as not to repeat the `$cast`** — without it, every place that clones ends up writing its own cast. It is the same idea as always: if you are going to repeat it, wrap it. |
| 31 | 5 | `dist`: `:=` against `:/` | **d** | **1 in 256** — `:=` gives weight 1 to *each one* of the 254 values in the middle, so the range weighs 254 against the 1 and 1 of the edges. To spread the weight *inside* the range you need `:/`. Both spellings compile and run: the difference only shows up in the coverage that does not go up. |
| 32 | 5 | `randomize() with {}` | **b** | **They add up** — the `with {}` adds constraints **for that call only**, and erases nothing. That is why it is the tool for closing a bin without writing a new class: three lines at the point of use, and the rest of the stimulus stays what it always was. And that is also why it clashes with a `dist` that already biases the same field: both have to hold at once. |
| 33 | 5 | constraint_mode() | **b** | **Switch off the constraint that gets in the way** — Verilator solves the `dist` by **picking a value first** and only then checking the rest, so the probability of success is the probability of the bin: measured, `with {A == 8'hFF}` solves 25 % of the time. `constraint_mode(0)` switches it off for that object alone and touches nobody else. It is exactly the line the `d5c` exercise asks for. |
| 34 | 5 | rand_mode() | **d** | **It stops being `rand`** — they are the two run-time knobs and they get mixed up often: `rand_mode(0)` takes **a field** out of the draw, `constraint_mode(0)` switches off **a constraint**. One picks *what gets drawn*, the other *which rules hold*. It is what you use to pin one operand by hand and go on randomizing the rest. |
| 35 | 5 | The order of resolution | **c** | **1 in 257** — the solver picks uniformly among the *solutions*, not among the values of each field: `es_reset=1` leaves a single combination (`A = 00`) and `es_reset=0` leaves 256. The *"any operation after a reset"* bin of the plan does not get filled, and the report does not say why. The answer in the language is `solve es_reset before A`; Verilator accepts it and **does not honour it**, so the portable workaround is to ask for the spread of the control field with a `dist`. |
| 36 | 6 | is_active | **a** | **The monitors, always; the sequencer and the driver are left at `null`** — watching is never optional: a passive agent goes on feeding scoreboard and coverage. What gets skipped is what *drives* the interface, because there somebody else is already driving it. |
| 37 | 6 | The handshake of the driver | **d** | **It hangs inside `finish_item()`, and without saying anything** — it is the classic mistake of the first week, and the symptom misleads: there is no error and no warning, time stops advancing and the objection never gets dropped. `get_next_item()` is a loan; `item_done()` is giving it back. |
| 38 | 6 | Scope of the config_db | **c** | **Both receive the same thing** — the `uvm_config_db` does not match by order nor by type: it matches by **path**. With `"*"` both entries describe the same components, so the last one wins. The scope is a path in the tree, not a label. |
| 39 | 6 | The sequencer | **d** | **Because of the base class we chose in transactions** — `uvm_sequencer #(T)` requires that `T` derive from `uvm_sequence_item`. If that day the transaction had extended a plain `uvm_transaction`, this `typedef` would not compile today. A decision of one section enabling the next. |
| 40 | 6 | super.build_phase() | **d** | **That mechanism is switched off** — `uvm_agent::build_phase` looks for `is_active` in the resource pool (it is in `code/.uvm/src/comps/uvm_agent.svh`, it can be opened). Without `super.build_phase()` that line never runs, and nobody warns you. Both ways are valid; what does not work is half of each one. |
| 41 | 6 | Object, not component | **a** | **It gets created, runs and is thrown away** — you can start several, one after the other, on the same sequencer. A component is built once in `build_phase` and lives to the end. That is why the stimulus cannot be a component: it changes from test to test, and sometimes within the same test. Out of that comes as well that it can be configured between the `create()` and the `start()`, the way `full_seq.count = 200` does. |
| 42 | 6 | start_item() | **b** | **You have the turn —nobody else is going to beat you to the driver— and you have not handed anything over yet** — and that is why the `randomize()` goes *after*: it is the last possible moment to choose the values, when you already know what state the DUT is in. That is late randomization, and it is where `pre_do()` and `mid_do()` hook on. |
| 43 | 6 | The way back | **a** | **After `finish_item()`** — there is no return channel at all: there is a shared handle and an agreement between the two parties. The REQ/RSP pair exists and is the formal mechanism, but almost nobody uses it: writing the result into the request is enough. This is what makes Fibonacci possible. |
| 44 | 6 | default_sequence | **c** | **It passes in zero seconds without sending a single piece of stimulus, and it lies** — a phase without an objection finishes as soon as it starts. It is the same kind of bug as the `new()` that eats the override: it does not break, it deceives. And in a regression of a thousand tests, the one that passes in zero seconds is one nobody looks at. |
| 45 | 6 | Sub-sequences | **b** | **It declares the mother-daughter relationship** — without it, the sequencer treats the two as independent sequences and they compete for the turn. With it, the daughter inherits the mother's turn and her priority in the arbitration. And for the parallel that is not enough: a `fork` / `join` around the `start()` is needed. |
| 46 | 7 | Immediate and concurrent | **a** | **Statement against declaration** — the immediate one runs when the thread goes past it; the concurrent one gets evaluated on its own, on every edge of its clock. It is to an `if` what the concurrent one is to an `always_ff`: one executes, the other gets instantiated. That is why only the concurrent one can describe something that lasts several cycles. |
| 47 | 7 | `\|->` against `\|=>` | **b** | **`\|=>` when the consequent comes out of a `<=`** — because `\|=>` *is* `\|-> ##1`, and the question to ask is how many edges later the spec promises it. With `\|->` against a registered signal the property does not pass vacuously: it **fails on every transaction**, because it compares against the old `done`. The one that passes quietly is the one whose antecedent never occurs — which is why it always goes with its `cover property`. |
| 48 | 7 | The sampling edge | **d** | **An assertion is worth what its sampling is worth** — the BFM writes the stimulus on the `negedge`, and on two consecutive `no_op` `start` goes down and comes back up between two `posedge`: the sampling does not see it go down. The stimulus gets sampled where the stimulus gets written. Stimulus on `negedge`, response of the DUT on `posedge`: zero errors. With a single clock there is no way. |
| 49 | 7 | The assertion that checks nothing | **a** | **Zero failures and zero evaluations look the same** — its antecedent may never have occurred, or `--assert` may be missing and it is not even being evaluated. That is why every assertion goes with its `cover property`: it is the only check of the check. In the section, `c_mult_3ciclos` stays at 0 and gives away that the real latency is four edges, not three. |
| 50 | 7 | Assertion or scoreboard | **c** | **Protocol → assertion. Data → scoreboard** — and it is not a preference: by the time the transaction reaches the scoreboard, the protocol is no longer there. Writing the check there would be rebuilding by hand the time the monitor has just erased. |
| 51 | 8 | The access string | **c** | **Green is not checked** — `uvm_reg_bit_bash_seq.svh:129-133` skips every field whose access starts with `WO` (*"you are not supposed to read them"*), and `do_check` takes it out of the comparison mask (`uvm_reg.svh:2782-2788`). The only trace is in the timing: bashing `CTRL` takes four transfers less. The right access is `WC` (or `W1C`), and with it the bit does get bashed. A `WO*` access is the cheapest way there is of switching a check off without noticing. |
| 52 | 8 | Automatic or explicit prediction | **a** | **The one who checks cannot believe the one who drives** — with `set_auto_predict(1)`, `model.CTRL.write()` updates the mirror at the moment of the call, before the bus has done anything: if the driver sends the transfer wrong, the model stays convinced. With the predictor, the mirror only changes once the monitor has seen the wire. It is the same drawing as the capstone scoreboard, with a library piece instead of a hand-written class. And it is free: the monitor and its analysis port **were already there**. |
| 53 | 8 | volatile | **a** | **The mirror stops being evidence** — a model predicts *"what I wrote is what I am going to read"*, and for a `volatile` field that sentence is false. The two `UVM_WARNING GET_MIRRORED_VAL/VOL` of the example are the library saying exactly that, and they are in the output on purpose. What does have to be checked gets checked where it is known: in the **scoreboard**, and in the model goes `set_compare(UVM_NO_CHECK)` on that field so that RAL does not invent an error. |
| 54 | 8 | mirror() against read() | **d** | **`mirror` is a register scoreboard in one word** — both read from the DUT; the difference is that `mirror` compares against what the model believed **before** the read, and if it does not match it reports a `uvm_error` without anybody writing a check. And a read *is* a prediction: both update the mirror afterwards. |
| 55 | 8 | Who knows about the bus | **b** | **The model does not know there is an APB underneath** — swap the adapter and the same model drives an AHB. The adapter is twenty lines, once per protocol, and it is the file that comes with a VIP you bought. Watch out for one thing: `bus2reg` is called **by the predictor too**, with the item the monitor saw, so an adapter that depends on something the driver put there works in one direction and fails in the other. |
| 56 | 8 | DPI and time | **b** | **Zero time, like any `function`** — to consume time you need `import "DPI-C" task`, and with a clarification almost every tutorial skips: C cannot block by itself. A DPI task consumes time **only** if it is declared `context` and from the C it calls back into an `export "DPI-C" task` of SystemVerilog, which is the one that waits for the edge. And at that point it is no longer a golden model, it is a bus model. |
| 57 | 8 | undefined reference | **c** | **The compiler does not cross the two declarations: the one that joins them is the linker** — hence an error about something that is written, right there, in plain sight. It is almost always one of two things: the name does not match letter for letter, or the file got compiled as C++ and the symbol came out mangled. That last one is literally the case here: Verilator hands the user's sources to the C++ compiler, so the `.c` needs its `extern "C"`. And there is no DPI flag: the `.c` goes on the `verilator` command line like any other source. |
| 58 | 8 | The scoreboard that never shouted | **d** | **The model has to be broken on purpose** — `vtalu_golden_bug(1)` mutates the multiplication and `run.sh` demands that the scoreboard shout. If it does not shout, the testbench is comparing against itself and nobody was going to find out: it is the same mutation test the capstone grader does with `+BUG=1`, from the other side of the wire. And the duplicated `enum` is real but it is a different symptom: if **every** comparison fails at once, it is the mapping; if one in six fails, it is the DUT. |
