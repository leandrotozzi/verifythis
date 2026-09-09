<!-- es-sha: b50aeb748a7a -->
<!-- .slide: class="quiz" -->

## Review · Day 6

#### *1 of 10 · is_active*

**An agent in `UVM_PASSIVE`, what does its `build_phase` build?**

- [ ] Nothing: a passive agent is an empty shell
- [ ] Everything the same as an active one, but without connecting the driver to the sequencer
- [x] The monitors and the analysis ports; the driver and the sequencer, no
- [ ] Only the sequencer, so it can receive sequences from another agent of the same env

> **The monitors, always; the sequencer and the driver are left at `null`** — watching is never optional: a passive agent goes on feeding scoreboard and coverage. What gets skipped is what *drives* the interface, because there somebody else is already driving it.

---

<!-- .slide: class="quiz" -->

## Review · Day 6

#### *2 of 10 · The handshake of the driver*

**The driver calls `get_next_item()`, drives the signals and forgets the `item_done()`. What happens?**

- [ ] Compilation error: UVM demands the complete pair
- [ ] The sequencer hands over the next item just the same, with a warning
- [ ] The item gets discarded and the scoreboard reports a mismatch on the next comparison
- [x] The sequence stays waiting in `finish_item()` and does not advance any more

> **It hangs inside `finish_item()`, and without saying anything** — it is the classic mistake of the first week, and the symptom misleads: there is no error and no warning, time stops advancing and the objection never gets dropped. `get_next_item()` is a loan; `item_done()` is giving it back.

---

<!-- .slide: class="quiz" -->

## Review · Day 6

#### *3 of 10 · Scope of the config_db*

**The `env` instantiates two agents and does both `set()` with the scope `"*"`. What does each one receive?**

- [ ] Both fail with `uvm_fatal`: the string `"config"` is duplicated
- [ ] Each one receives its own, in order of creation
- [x] Both receive the same one: the second `set()` overwrites the first
- [ ] The first receives its config and the second is left with `cfg == null`

> **Both receive the same thing** — the `uvm_config_db` does not match by order nor by type: it matches by **path**. With `"*"` both entries describe the same components, so the last one wins. The scope is a path in the tree, not a label.

---

<!-- .slide: class="quiz" -->

## Review · Day 6

#### *4 of 10 · The sequencer*

**`typedef uvm_sequencer #(command_transaction) sequencer;` compiles without touching the transaction of the transactions. Why?**

- [ ] Because it is registered in the factory with `` `uvm_object_utils ``
- [ ] Because `uvm_sequencer` accepts any `uvm_object`
- [ ] Because the driver does the `$cast` internally
- [x] Because `command_transaction` extends `uvm_sequence_item`

> **Because of the base class we chose in transactions** — `uvm_sequencer #(T)` requires that `T` derive from `uvm_sequence_item`. If that day the transaction had extended a plain `uvm_transaction`, this `typedef` would not compile today. A decision of one section enabling the next.

---

<!-- .slide: class="quiz" -->

## Review · Day 6

#### *5 of 10 · super.build_phase()*

**Instead of the config object, you put `is_active` straight into the `uvm_config_db`. In this course the agent starts up active all the same. Why?**

- [ ] Because `is_active` is `protected` and the `config_db` cannot write it
- [ ] Because the `config_db` does not accept enumerated types, only `int` and `string`
- [ ] Because `is_active` is fixed in the constructor and `build_phase` arrives late
- [x] Because the one who reads it is `uvm_agent::build_phase`, and nobody calls `super`

> **That mechanism is switched off** — `uvm_agent::build_phase` looks for `is_active` in the resource pool (it is in `code/.uvm/src/comps/uvm_agent.svh`, it can be opened). Without `super.build_phase()` that line never runs, and nobody warns you. Both ways are valid; what does not work is half of each one.

---

<!-- .slide: class="quiz" -->

## Review · Day 6

#### *6 of 10 · Object, not component*

**What is the practical difference of a `uvm_sequence` being a `uvm_object` and not a `uvm_component`?**

- [ ] That it cannot be registered in the factory nor overridden
- [x] That it gets created, runs and is thrown away
- [ ] That it cannot have `rand` fields nor constraints
- [ ] That UVM builds it in `build_phase`, like any other class of the tree

> **It gets created, runs and is thrown away** — you can start several, one after the other, on the same sequencer. A component is built once in `build_phase` and lives to the end. That is why the stimulus cannot be a component: it changes from test to test, and sometimes within the same test. Out of that comes as well that it can be configured between the `create()` and the `start()`, the way `full_seq.count = 200` does.

---

<!-- .slide: class="quiz" -->

## Review · Day 6

#### *7 of 10 · start_item()*

**`start_item(command)` has just come back. What is it that this guarantees?**

- [ ] That the driver has already received the item and is driving the signals
- [x] That the sequencer gave the turn to this sequence
- [ ] That the `randomize()` has already been resolved with the constraints of the class
- [ ] That the objection of the phase is already raised by the sequencer

> **You have the turn —nobody else is going to beat you to the driver— and you have not handed anything over yet** — and that is why the `randomize()` goes *after*: it is the last possible moment to choose the values, when you already know what state the DUT is in. That is late randomization, and it is where `pre_do()` and `mid_do()` hook on.

---

<!-- .slide: class="quiz" -->

## Review · Day 6

#### *8 of 10 · The way back*

**At what moment does `command.result` have a value that can be read?**

- [ ] As soon as `start_item()` came back
- [ ] When the `result_monitor` publishes it through its analysis port
- [x] When `finish_item()` came back, because the driver wrote it before calling `item_done()`
- [ ] Never: to receive a response you have to use the REQ/RSP pair of `uvm_sequence #(REQ, RSP)`

> **After `finish_item()`** — there is no way back at all: there is a shared handle and an agreement between the two parties. The REQ/RSP pair exists and is the formal mechanism, but almost nobody uses it: writing the result into the request is enough. This is what makes Fibonacci possible.

---

<!-- .slide: class="quiz" -->

## Review · Day 6

#### *9 of 10 · default_sequence*

**You configure a `default_sequence` through `uvm_config_db` and forget the `set_automatic_phase_objection(1)`. What happens?**

- [ ] `uvm_fatal` in `build_phase`: the sequence does not find the sequencer
- [ ] It runs just the same: when there is a `default_sequence`, the sequencer raises the objection on its own
- [x] The `main_phase` finishes at t=0 and the test passes with 0 errors
- [ ] The simulation hangs waiting for an objection nobody drops

> **It passes in zero seconds without sending a single piece of stimulus, and it lies** — a phase without an objection finishes as soon as it starts. It is the same kind of bug as the `new()` that eats the override: it does not break, it deceives. And in a regression of a thousand tests, the one that passes in zero seconds is one nobody looks at.

---

<!-- .slide: class="quiz" -->

## Review · Day 6

#### *10 of 10 · Sub-sequences*

**`full_sequence` starts its daughters with `reset_seq.start(get_sequencer(), this)`. What is the second argument for?**

- [ ] To pass it the sequencer, because `get_sequencer()` only returns the type
- [x] To declare the daughter a sub-sequence of the mother
- [ ] So the daughter runs in a separate thread, in parallel with the mother
- [ ] To register the daughter in the factory under the name of the mother, so it can be overridden

> **It declares the mother-daughter relationship** — without it, the sequencer treats the two as independent sequences and they compete for the turn. With it, the daughter inherits the mother's turn and her priority in the arbitration. And for the parallel that is not enough: a `fork` / `join` around the `start()` is needed.
