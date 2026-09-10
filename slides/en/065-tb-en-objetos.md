<!-- es-sha: de322b440014 -->
## A testbench without a single module

#### *The same testbench, without a single module*

- This section **adds no functionality**:
  it verifies the same as the interfaces and BFM testbench
- What changes is what it is made of. The three modules —tester, scoreboard,
  coverage— become three **classes**, and the `initial` becomes a method
- The piece that binds them appears: a `testbench` class that instantiates the others,
  hands them the BFM and launches their threads. Nobody instantiates it for you
- It is the **last version without UVM**, and that is why it is worth looking at closely: everything
  this class does by hand, from the tests on the library is going to do
- The question to walk out of the section with: *which part replaces which?*

Note:
The real goal of the section is not to teach anything new, it is to leave a point of
comparison. If the student can look at `testbench.svh` and say "this is the env,
this is the build_phase, this is the run_phase", day 3 starts downhill.
It is worth writing the table on the board before showing the code, and coming back to it
at the end of day 3:

| Here, by hand | From the tests on |
| `testbench.execute()` that does `new()` on the three | `build_phase` of the env |
| passing the BFM through the constructor | `uvm_config_db` |
| `fork ... join_none` | UVM runs one `run_phase` per component |
| `$finish` inside the tester | objections |

And say out loud what can be seen on its own: there is not a single `module` in the classes of the
testbench. The modules were left for the DUT, the clock and the interface — which is
precisely what gets synthesized.

---

## A testbench without a single module

- A testbench of modules works until it has to be reused: to change the
  stimulus you have to edit the module, and to have two versions you have to copy it
- With classes, changing the stimulus is **extending a class**, and the two versions
  live side by side. That is all OOP buys you here

#### *The VTALU TB, piece by piece*

- top: Instantiates the testbench class
- testbench: Top-Level Class
- tester: Generates the stimulus
- scoreboard: Checks that the VTALU is working
- coverage: Captures the functional coverage information

![The object tree: top elaborates, and inside live the testbench class and its three pieces](res/diagrams/en/tb-en-objetos_arbol.svg)
<!-- .element: class="grande" -->

Note:
It is the same testbench as interfaces and BFM, but in objects: what changes is the shape, not
what it does. If possible, show them side by side.
The drawing is the one to be able to redraw from memory at the end of the day, and
the line that splits it in half is the one that matters: above, what gets
**elaborated** —the module, the DUT, the interface—; below, what somebody has to
**create**. An object nobody creates is a null handle, and that is the mistake of
the first afternoon.
It is the last version without UVM. From the tests on the same thing gets assembled by UVM, and the
student has to be able to say which part replaces which.

---

## A testbench without a single module

#### *The top: the only thing that is still a module*

- The `top` is still a module, and it is going to stay that way until the end of the
  course: classes do not get elaborated, somebody has to exist before time 0
- It imports the package with the classes, instantiates the DUT and the BFM, and declares the
  handle to the `testbench`
- Inside the `initial`, two lines: `new(bfm)` and `execute()`

{{code:code/u3/tb-en-objetos/top.sv}}

Note:
The `top` is still a module and it is going to stay that way until the end of the course,
even with UVM. The reason is that **classes do not get elaborated**: somebody has to
exist before time 0 to instantiate the DUT, the interface and the clock.
The detail to point a finger at is how the BFM gets passed: here it gets
handed to the constructor, `new(bfm)`, and it works because the `top` knows the class.
In UVM that line is not going to exist — the test gets created by the factory and nobody can
pass it arguments. That is why the `uvm_config_db` shows up in the tests.
A good question to leave hanging: why is the package `import` before
everything else? Because the classes live in a package and the module has to see them. It is the
first time the compilation order matters, and it will not be the last.

---

## A testbench without a single module

#### *The `testbench` class: the one that assembles and starts*

- There is **one** object above everything else that instantiates the others, hands them what
  they need and launches their threads. Every OOP testbench has one
- Here we write it by hand: three `new()` and a `fork ... join_none`
- From the `env` on that class is going to be called `uvm_env`, the `new()` are going to be
  `type_id::create()` in the `build_phase`, and the `fork` UVM is going to do on its own

{{code:code/u3/tb-en-objetos/tb_classes/testbench.svh}}

Note:
This is the class UVM is going to replace, so it is worth reading it line by
line: `new()` on the three objects, `fork ... join_none` to start them, and
that is it. That is an `env` written by hand.
Two things to flag. The first is the `virtual vtalu_bfm bfm`: the word
`virtual` here has **nothing to do** with the virtual methods of polymorphism.
A virtual interface is a handle to an interface that is going to be assigned later
on — it is the equivalent, in the world of objects, of the port list of a
module. It is the third meaning of `virtual` in SystemVerilog and that is why it is worth
naming it out loud.
The second is the `join_none`: the three objects run in separate threads and
`execute()` returns right away. If it were `join`, the testbench would wait for the
three to finish and the scoreboard never finishes. It is the same decision UVM
takes on its own when it runs a `run_phase` per component.
And one that always gets asked: who ends the simulation? The tester's `$finish`, inside
`execute()`. It is ugly and it shows: one object decides for everybody. In
the tests that becomes an objection, which is the tidy form of the same thing.

---

## A testbench without a single module

#### *The `tester` class: the stimulus, with no wires*

- It sends a thousand random operations, with the same bias to the edges as the conventional
  testbench: the goal is still to fill the bins of the covergroup
- Against the modular version two things change and nothing else:
  - the BFM arrives through a **variable** —a *virtual interface*— instead of through a
    port list
  - the `initial` is now a method, `execute()`, that somebody has to call

{{code:code/u3/tb-en-objetos/tb_classes/tester.svh#execute}}

Note:
There is a trap here **put in on purpose** and it is worth not giving it away now: look at the
declaration of `get_op()`. It says `protected function`, not `protected virtual
function`. Without `virtual`, `execute()` is always going to call this class's one,
even if the object is of a derived class — which is exactly what they saw in
polymorphism with `servir()`.
That is the day 2 exercise, and it is good that they walk into it: inheritance does not
show until somebody writes `virtual`, and that is understood much better by
suffering it than by reading it.
The other thing to point out is what is **not** in this class: the protocol.
`reset_alu()` and `send_op()` still live in the BFM, the same as in interfaces and BFM,
and the tester calls them with `bfm.send_op(...)`. That is the whole point of the BFM and
that is why it holds without changes until the end of the course: the class above asks for an
operation, and it does not even know a `done` exists.
And the detail you see at the start of `execute()`: the four directed
operations before the `repeat (1000)` are not decoration. They are the reset, the
multiplication after the reset and the repeated mult — that is, three rows of the
verification plan of the conventional testbench that the random should not be left to wait for.

---

## A testbench without a single module

#### *The scoreboard: the `always` became a task*

- A sensitivity list does not exist in a class. What replaces it is a
  `forever` with the wait inside — same semantics, written as sequential
  code

{{code:code/u3/tb-en-objetos/tb_classes/scoreboard.svh#execute}}

Note:
The translation to point out: the `always @(posedge done)` of the modular
testbench is a `forever begin @(posedge bfm.done) ... end` here. It is the same
wait, written as sequential code inside a method. An object has no
sensitivity list; it has a task that blocks.
The `#1` of the first line is one of those details that get paid for dearly: without it, the
scoreboard reads the signals at the very instant `done` goes up and can
eat a delta race. With it, it reads when everything has settled. It is the
reason verification samples on the edge the design does **not** use.
And what this scoreboard still does wrong, to leave it hanging: it reads the operation
off the **wire** (`bfm.op_set`) at the moment of the result. It works because the
protocol forces the operands to stay stable, but it is fragile — the day
the DUT has several operations in flight, it breaks. In the analysis ports the scoreboard
is going to compare against a queue of commands the monitor sends it, and that does
scale.

---

## A testbench without a single module

#### *The `coverage` class: the covergroup inside an object*

{{code:code/u3/tb-en-objetos/tb_classes/coverage.svh#sampling}}

- The covergroup is **the same** as the conventional testbench's, line by line. What changed is
  where it lives
- In a module, declaring the covergroup was enough. In a class it has to be
  built: the class's `new()` does `op_cov = new()`
- The `execute()` is the `always @(negedge clk)` from before, written as a `forever`:
  it copies the BFM signals and calls `sample()`

Note:
The `op_cov = new()` inside the constructor is the trap of the slide: in a
module the covergroup gets instantiated on its own, in a class it does **not**. If you forget it, the
code compiles, it runs, and the report says 0 %. It is the same silent trap as the conventional testbench's, with one more turn of the screw.
The transition bins are still inside `` `ifndef VERILATOR ``, the same as in the conventional testbench, and for the same reason: Verilator 5.052 still does not compile them.
What has to be said before the analysis ports: here the sampling happens on the **clock
edge**, that is, cycles get counted. When the `coverage` is a subscriber it
is going to sample when **a command arrives**, and there operations get counted —
which is what the verification plan asked for from the conventional testbench on.

---

## A testbench without a single module

#### *The map of day 3: what replaces what*

| Here, by hand | From the tests on |
| --- | --- |
| `testbench.execute()` with three `new()` | the `build_phase` of the `env` |
| passing the BFM through the constructor | `uvm_config_db` |
| `fork ... join_none` | UVM runs one `run_phase` per component |
| `$finish` inside the tester | objections |
| picking the tester by editing the code | `set_type_override` of the factory |
| `$display` that gets put in and deleted | `` `uvm_info `` and the verbosity ceiling |

- This is the **complete** testbench, without UVM and with nothing missing. It works
- Everything that comes on day 3 replaces one row of this table, **and nothing else**
- We come back to this slide at the close of the day, to cross them out

Note:
This is the slide worth writing down, because it is the whole map of day 3.
The strong claim has to be made explicit: **UVM adds no functionality
here**. The testbench of this unit does everything the env's is going to do. What it adds is convention — that the left-hand column is solved
the same way in every testbench in the world.
And the honest question that is going to come up: "so what for?". So that whoever
joins the project knows where to look without reading the whole testbench, and so that the
new tester costs four lines instead of a class. Both benefits are of
scale, and that is why in a hundred-line example UVM looks like too much — it has to be
said that way, instead of selling smoke.
At the close of day 3, with the `env` and the override already seen, you come back here and read
the right-hand column straight through. That is where the day closes on its own.

---

## A testbench without a single module

#### *Summary of the unit*

- The day 1 testbench **without a single module**: the same three pieces, plus
  the class that binds them —`testbench`—, which is the direct ancestor of the
  `uvm_env`
- The `top` is still a **module** and it will be until the end, and the BFM
  arrives through a **virtual interface**: it is the only way a class has of
  touching signals
- It is the **last version without UVM**. From here on, every piece we write by
  hand has a class of the library that replaces it — `execute()` is going to be
  the `run_phase`

Note:
The slide to close the whole of day 2 with, because it leaves the bridge
built. The question to leave posed: *which part replaces which?*
Day 3 answers it piece by piece, and it starts downhill if the student walks out
of here able to draw the object tree on the board.
And the argument for why the whole day was worth it: with modules, changing the
stimulus is editing the file. With classes it is extending a class, and the two
versions live side by side. That is the exercise that follows.
