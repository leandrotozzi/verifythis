<!-- es-sha: 38003c62dcd2 -->
<!-- .slide: class="quiz" -->

## Review · Day 3

#### *1 of 7 · `uvm_test`*

**What does `+UVM_TESTNAME=add_test` let you do that you could not do before?**

- [x] Pick the test on an already compiled testbench, without recompiling
- [ ] Run the simulation faster
- [ ] Change the DUT without recompiling
- [ ] Lower the verbosity of the messages

> **Pick the test without recompiling** — UVM reads that plusarg and asks the **factory** for the test by name. It is the difference between 1000 tests × 5 minutes of compilation and a single compilation.

---

<!-- .slide: class="quiz" -->

## Review · Day 3

#### *2 of 7 · UVM Phases*

**In what order does UVM walk the hierarchy in `build_phase` and in `connect_phase`?**

- [ ] Both from the top down
- [ ] Both from the bottom up
- [x] `build_phase` top-down, `connect_phase` bottom-up
- [ ] In the order the components were declared

> **Build top-down, connect bottom-up** — and it makes sense: you cannot connect a component that does not exist yet, so first the whole hierarchy gets built and only then does it get connected.

---

<!-- .slide: class="quiz" -->

## Review · Day 3

#### *3 of 7 · Objections*

**What are `raise_objection()` / `drop_objection()` for in the `run_phase`?**

- [ ] For reporting scoreboard errors
- [x] For keeping the simulation alive while the component has work
- [ ] For synchronizing two threads
- [ ] For registering the class in the factory

> **So that the phase does not end early** — every `run_phase` runs in parallel, each one in its thread, and the phase ends when **the last objection drops**. Without raising it, the simulation ends on you at time 0.

---

<!-- .slide: class="quiz" -->

## Review · Day 3

#### *4 of 7 · The env*

**What does each one get: `uvm_env` and `uvm_test`?**

- [ ] `env` generates the stimulus; `test` assembles the structure
- [ ] Both do the same thing, `env` is optional
- [ ] `env` runs the DUT; `test` runs the scoreboard
- [x] `env` assembles the structure of the TB; `test` defines which stimulus gets applied

> **Structure vs. stimulus** — each class does **one single thing well**. That is why the `env` almost always has only `build_phase` and `connect_phase`, and the test almost always has only a factory override.

---

<!-- .slide: class="quiz" -->

## Review · Day 3

#### *5 of 7 · Factory override*

**`set_type_override()` replaces `base_tester` with `add_tester`. When does it have to be called?**

- [x] Before the `build_phase` that creates the object runs
- [ ] At any moment: the factory applies it retroactively
- [ ] After the `connect_phase`
- [ ] Inside the `run_phase` of the tester

> **Before the `build_phase`** — the factory decides what to build **at the moment of the `create()`**. If the override arrives late, the `env` has already instantiated the base class and it does nothing.

---

<!-- .slide: class="quiz" -->

## Review · Day 3

#### *6 of 7 · Verbosity*

**The verbosity ceiling (`+UVM_VERBOSITY=UVM_HIGH`), which macros does it act on?**

- [ ] On all four: info, warning, error and fatal
- [x] Only on `` `uvm_info ``
- [ ] On error and fatal only
- [ ] On none: it only changes the format of the message

> **Only on `` `uvm_info ``** — warnings, errors and fatals are **immune** to the verbosity ceiling, and it is right that they should be: nobody wants to switch off an error by accident. For those you need the *actions* mechanism.

---

<!-- .slide: class="quiz" -->

## Review · Day 3

#### *7 of 7 · Report actions*

**You want to silence the `` `uvm_error `` of a scoreboard somebody else is fixing. Where does the `set_report_severity_action_hier()` go?**

- [ ] In the `build_phase` of the `env`
- [ ] In the `run_phase` of the test
- [ ] In the constructor of the scoreboard
- [x] In the `end_of_elaboration_phase` of the `env`

> **In `end_of_elaboration_phase`** — it has to be **after** the hierarchy is built (otherwise the component does not exist yet) and **before** the simulation starts. That phase is exactly that window.
