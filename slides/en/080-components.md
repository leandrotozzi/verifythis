<!-- es-sha: e2133b823a46 -->
## Components and phases

#### *A component is what is in the tree, and the tree is walked by UVM*

- A testbench has three different things: the **structure** —what parts there are and
  how they connect—, the **sequences** —which commands, in what order— and the
  **data**. This unit is the first one; the other two are day 6
- In the tests the test did `new()` on three loose objects and called them
  itself. That is not a structure: it is a long function
- A `uvm_component` is a **node with a name and a parent**. UVM assembles the whole
  tree and then walks all of it calling **phases**, in an order it
  guarantees
- Turning a class into a component is four steps, always the same ones:

  1. extend `uvm_component` or one of its daughters
  2. register it with `` `uvm_component_utils() ``
  3. the minimum constructor: `(string name, uvm_component parent)`
  4. override the phases it needs

Note:
The sentence on the slide is the one that orders the unit: *a component is what is in
the tree*. Everything else —the name, the parent, the phases, the `print_topology` of
the agents— comes out of there.
The practical consequence that has to be said out loud: if something is not a
component, UVM does not see it. It does not build it, it does not call phases on it and it does not show up in the
topology. Later on we are going to have objects that on purpose are **not**
components —the transactions— and there the distinction gets charged for.
The three axes —structure, sequences, data— work as a map of the rest of the
course: components and `env` are structure, transactions are data, sequences are
sequences.

---

## Components and phases

#### *Intro UVM phases*

- Every uvm component has these phase methods by inheritance
- UVM creates the TB and goes calling these methods in order
- The phases are *methods*: they get overridden like any other virtual method.
  Whether it is also worth calling `super` is the topic of the next slide

- *function void build_phase(uvm_phase phase):* UVM creates the TB (top-down). UVM components get instantiated in this method. If you try to instantiate them anywhere else it is an error
- *function void connect_phase(uvm_phase phase):* Connecting components
- *function void end_of_elaboration_phase(uvm_phase phase):* UVM calls it once it has created and connected every component
- *task run_phase(uvm_phase phase):* UVM runs this task in its own thread. Every run_phase runs simultaneously
- *function void report_phase(uvm_phase phase):* It runs when the last objection of the test drops. It shows Results

Note:
Three things that have to be said no matter what: build_phase is top-down, connect_phase is
bottom-up, and every run_phase runs in parallel, each one in its thread.
And the classic mistake: instantiating components outside build_phase. UVM does not warn you
kindly.

---

## Components and phases

#### *And what about `super.build_phase()`?*

```systemverilog
// uvm_component.svh -- uvm-core 2020.3.1, exactly as it is
function void uvm_component::build_phase(uvm_phase phase);
   build();            // -> apply_config_settings(): the automatic config
endfunction

function void uvm_component::connect_phase(uvm_phase phase);
   connect();          // -> return;  it is empty, like all the others
endfunction
```

- `build_phase` is the **only** phase that does anything in `uvm_component`: it walks the
  `uvm_config_db` and assigns on its own the fields you registered with `` `uvm_field_* ``
- The course **does not use those macros** —the fields get read by hand with
  `uvm_config_db::get()`—, so there is nothing to apply. That is why no
  `build_phase` in `code/` calls `super`: **it is not an oversight**
- The moment a `` `uvm_field_int `` shows up in your project, it becomes
  mandatory: without it the automatic config does not happen, the field stays at its
  default and **nobody warns you**
- And the order matters: whatever has to be decided *before* the children get
  built goes before the `super`. The `set_type_override` of
  `add_test` (the transactions) is exactly that

Note:
This slide exists because the student is going to see `super.build_phase(phase)` in every
piece of material on the internet and in the code of the course it is not there. The honest answer is not
"they forgot": it is that without the field macros the call does nothing.
And take the chance to name the underlying difference: there are two ways of configuring a
component. The automatic one (`` `uvm_field_* `` + config_db, magic by macros) and the
manual one (`uvm_config_db::get()` in the build_phase, which is the one the course uses).
The manual one is more code and vastly easier to debug — the field macros
generate hundreds of lines you are never going to read.
If somebody asks why the other phases usually get called anyway: habit and
cheap insurance. In `uvm_component` they are `return;`, but if tomorrow you inherit from
an intermediate class that does implement them, the call is already there.

---

## Components and phases

#### *The full picture: there are nine, not five*

| Phase | What for | Order |
| --- | --- | --- |
| `build_phase` | instantiate the components | **top-down** |
| `connect_phase` | connect the ports | bottom-up |
| `end_of_elaboration_phase` | hierarchy ready, before simulating | bottom-up |
| `start_of_simulation_phase` | last warning before time 0 | bottom-up |
| `run_phase` | **task**: this is where the simulation happens | one thread each |
| `extract_phase` | gather the data of the run | bottom-up |
| `check_phase` | decide whether it passed or not | bottom-up |
| `report_phase` | print the verdict | bottom-up |
| `final_phase` | close files and exit | bottom-up |

- The course uses five. The other four exist, they are empty, and you are going to see them

Note:
The table is there so that nobody leaves believing UVM has five phases: it has
nine common ones and twelve runtime ones. The course uses five because with a single agent
that is enough, and that has to be said — it is not that the others do not matter.
The three you are most likely to run into outside: `start_of_simulation_phase` is where
people print the configuration banner of the test; `check_phase` is where a
tidy scoreboard decides the verdict, instead of counting errors along the
way; and `report_phase` is the one they have already seen.
That `extract` / `check` / `report` are separate has a concrete reason: they are
bottom-up, so a child scoreboard finishes extracting before the parent env
decides. If you do the three things in `report_phase`, you lose that guarantee.
The question that orders the table: why is `build_phase` the only top-down one?
Because a parent has to exist in order to create its children. All the others
need the opposite — that the children are already there.

---

## Components and phases

#### *And inside the `run_phase`, a schedule*

```
   reset          configure          main          shutdown
  pre  post      pre     post      pre   post     pre    post
```

- **In parallel** with `run_phase`, UVM walks twelve *runtime* phases, all of them
  `task`, in that order
- They are there to coordinate components from different teams without hand-made flags:
  nobody sends traffic in `main` until **everybody** finished `reset`
- Each one has its own objection, with the rule from the tests: a runtime
  phase without an objection **ends the moment it starts**
- The course uses `run_phase` and nothing else — with a single agent there is nothing to
  coordinate. But the `default_sequence` of day 6 hooks into **`main_phase`**

Note:
This slide exists so that `main_phase` does not show up for the first time on day 6.
The exact distinction, which confuses everybody: `run_phase` and the schedule
`reset → configure → main → shutdown` run **at the same time**, not one inside the
other. A component can implement either of the two paths; what is not
advisable is mixing them in the same testbench, because then nobody knows what
runs when.
The honest question is "so which one do I use?". For a testbench of a single
block, `run_phase`, which is what the course does. The schedule earns its
keep in integration: the agent of the configuration bus finishes its `configure`
and only then does the data one start its `main`, without either of the two teams
having had to write a `uvm_event` or a shared flag.

---

## Components and phases

#### *The scoreboard, now as a component*

{{code:code/u4/components/tb_classes/scoreboard.svh|lines=1-18}}

- The four steps, in order: it extends `uvm_component`, it registers itself, constructor
  `(name, parent)`, and an override of `build_phase`
- The underlying change does not show in the diff: before, the **test** received the BFM and
  handed it to the scoreboard through the constructor. Now the scoreboard **asks for it
  itself** from the config_db
- The `run_phase` is the `execute()` of the object-based testbench without touching a comma: the
  check did not change, what changed is who starts it

Note:
The point of the slide is self-sufficiency. A component that needs somebody
to hand it its dependencies forces that somebody to know them, and the test
ends up being a delivery service for handles it does not use. With the config_db, the test does not
know that the scoreboard needs a BFM.
That is exactly what makes the `env` able to exist: if
every component configures itself, the parent only has to build it.
The price has to be said too: the dependency stopped being in the
constructor, where it could be seen, and moved into a string. A misspelt `"bfm"` compiles. That
is why the `if (!get(...)) uvm_fatal` is not optional.

---

## Components and phases

#### *The test builds the tree and steps aside*

{{code:code/u4/components/tb_classes/random_test.svh}}

- The three `new("name", this)` are what creates the tree: `this` is the parent, and
  the string is the name that is going to come out in `print_topology` and in every message
- They go in `build_phase` **and nowhere else**. In the constructor there is no
  hierarchy yet; after `build_phase`, UVM has already moved on
- `random_test` **has no `run_phase`**: its job finished when the tree
  was assembled. The three children have theirs, and they run in parallel

Note:
It is the change of mindset of the unit, and it is worth saying it in these words:
the test stopped *doing* the test. Now it assembles it and steps aside.
The objection also moved: it is no longer raised by the test, it is raised by the
components that have work — or, in this example, by the tester. Worth showing
`random_tester.svh` for a second so that it can be seen.
And the trap that is going to show up on its own: `new()` works here because the type is
written in the declaration. In the env that gets replaced by
`type_id::create()`, and that is the change that enables the overrides. Not yet,
but it is worth planting.

---

## Components and phases

#### *The second test: it inherits, and it copies anyway*

{{code:code/u4/components/tb_classes/add_test.svh}}

- `add_test` extends `random_test`, so it inherits `coverage_h` and
  `scoreboard_h`. It only redeclares `tester_h`, with another type
- But the `build_phase` is **written out again in full**, and the three lines are
  identical except for one. Inheriting the class was not enough to inherit the structure
- And there is something worse hidden: `add_tester tester_h;` **shadows** the `tester_h` of
  the base class. They are two different variables with the same name
- It is the same problem as the tests, in disguise. The env solves it for
  real: **one** structure, and the factory substitutes the piece that changes

Note:
This is the slide that has to be left uncomfortable. If the student walks out thinking "this
is still wrong", the env explains itself.
The shadowing of the handle deserves a minute: in the base class there is a
`random_tester tester_h` and here an `add_tester tester_h`. Any method
inherited from `random_test` that uses `tester_h` is going to see the base one, which stayed at
`null`. Here it does no harm because there is none, but it is a time bomb and it is
exactly the kind of silent mistake the course goes after.
The hook: in the `env` there are not two tests, there is one; and `add_test` becomes a
line of `set_type_override_by_type`.

---

## Components and phases

#### *Summary of the unit*

- A `uvm_component` is a **node with a name and a parent**. UVM assembles the tree
  with those two pieces of data and then walks it on its own
- Turning a class into a component is **four steps, always the same ones**:
  extend, register with the macro, the two-argument constructor, and the
  phases
- The **phases** are virtual methods that UVM calls **in order**: `build_phase`
  (top-down), `connect_phase`, `end_of_elaboration_phase`, `run_phase`,
  `report_phase`
- Components get instantiated **in the `build_phase` and nowhere else**
- Every `run_phase` runs **in parallel**, each one in its thread. None of them
  decides on its own when the simulation ends: that is the **objections**
- `build_phase` is the only phase that does anything in `uvm_component`, and that is why it is
  the only one where `super.build_phase()` changes the behaviour

Note:
The unit that turns the testbench into something UVM can walk, and with that
the tools that did not exist before show up: `print_topology()` shows the
tree, and the `uvm_config_db` can use paths because now there are paths.
The `super.build_phase()` deserves the pass we gave it because it is the most
repeated question in the forums: not calling it switches off the automatic assignment of the
fields registered with `` `uvm_field_* ``. This course does not use them, so it does not call it —
but what is not valid is doing half of each.
