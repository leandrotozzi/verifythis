<!-- es-sha: 04f915233349 -->
## Polymorphism

#### *A `trago` variable, a `fernet` object: which `servir()` runs?*

![UML diagram of the trago classes](res/diagrams/uml-poli.svg)
<!-- .element: class="grande" -->

- A `fernet` **is** a `trago`, so storing it in a `trago` variable
  compiles and is legal
- The question is the other one: when you call the method through that variable, does
  SystemVerilog look at the **type of the variable** or at the **type of the object**?
- The default answer is the one you do not want, and the word that changes it is
  a single one

Note:
It is the concept that holds up everything that comes: the factory, the overrides, the
transactions. Whoever gets lost here loses the rest of the course, so it is not worth
moving on until everybody sees why the variable can be of the base class.
It is worth taking a vote before showing the code: "what does it print?". Half the
room says *"Fernet"*, and seeing that they are wrong is what fixes the concept.
And warn about it before they ask: in SystemVerilog `virtual` is
overloaded — virtual method, virtual class and virtual interface are three different
things. Here it is the first one.

---

## Polymorphism

#### *The three classes: a `trago` that does not know how to serve itself*

{{code:code/u3/polimorfismo/01-sin-virtual/not_virtual.sv#three-classes}}

- `trago` defines `servir()` with a `$fatal`: the base class does not know what it
  gets served with, and it says so loudly
- `fernet` and `mojito` extend `trago` and **redefine** `servir()`, each one
  with its own
- `mojito` —which does not fit on the screen— is the same as `fernet`, with another
  `$display`

Note:
The `$fatal` in the base class is a pattern you see a lot and that in two slides
we are going to replace with something better: if the method cannot be implemented here, the
right thing is not to explode in simulation, it is not to let it compile.
That the three classes have a method with the same name and the same signature is what
makes everything that follows possible. Now it remains to decide **which one runs**, and that
is not yet said anywhere in the code.
The whole file is in `code/u3/polimorfismo/01-sin-virtual/not_virtual.sv`.

---

## Polymorphism

#### *Without `virtual` the variable rules, and that breaks*

{{code:code/u3/polimorfismo/01-sin-virtual/not_virtual.sv#the-calls}}

- The first two calls work: the variable `fernet_h` is of type `fernet` and so is
  the object
- The third one **explodes**. `trago_h` points at a `fernet`, but since the method is
  not virtual, SystemVerilog resolves at **compile time** by the type of the
  variable, and calls `trago`'s `servir()`
- It is called *static binding*: the decision of which code to run is already taken
  before the object exists

Note:
This is worth running: `bash code/u3/polimorfismo/01-sin-virtual/run.sh`. The example
ends in `$fatal` on purpose, and the `run.sh` gives PASS precisely when that
message shows up.
The question that always comes: "and why does `hielos` come out right?". Because
fields are never virtual: the variable sees the fields of its own type, and
`hielos` is in `trago`. Methods are the only thing that can be resolved by
object, and only if you ask for it.

---

## Polymorphism

#### *Virtual methods: one word, and now the object rules*

{{code:code/u3/polimorfismo/02-virtual/virtual.sv#trago.servir}}

- It is the **only** difference between `01-sin-virtual` and `02-virtual`: the keyword
  `virtual` on the method of the base class
- With that the call gets resolved at **simulation time**, looking at the object inside
  the variable — *dynamic binding*
- `trago_h.servir()` now serves a fernet or a mojito, without whoever wrote
  that line knowing which one they are going to get
- That is the whole idea: **whoever uses the object stops being the one who picks the type**

Note:
Worth running the two examples one after the other and showing the diff: one word.
A detail that always gets asked: `fernet` and `mojito` do **not** write `virtual`
on their `servir()`, and they are virtual all the same. Once the method is virtual in
the base, it is virtual for all of its descendants. Writing it anyway does no harm and plenty
of people do it out of tidiness.
The rule of thumb for the rest of the course: in verification, **every method you might
want to redefine goes virtual**. UVM does it that way — `build_phase`,
`run_phase`, `do_copy`, `do_compare` are all virtual, and that is why the override
of the env works.
The cost exists and it is real —a method table and an indirect jump— but in a
testbench you are never going to measure it. In synthesizable RTL there are no classes, so
the discussion does not apply.

---

## Polymorphism

#### *Abstract classes: moving the error to compile time*

- The `$fatal` of `trago` finds out **late**: it compiles, it runs, and it explodes in the
  middle of the simulation. In an overnight regression that is a lost run
- SystemVerilog allows declaring an **abstract class** —`virtual class`—: it only
  serves as a base, **it cannot be instantiated**
- Inside it can declare **pure virtual methods**: methods with no body
- Extending the class **forces** you to redefine them. If not, it is a **compile
  error**
- The error did not go away: it moved to a moment where it comes out cheap

Note:
This is the slide to leave clear, because the criterion repeats through the whole
course: *the sooner it fails, the better*. Compile time better than simulation,
simulation better than silicon.
In verification a compile error is **good news**: the overnight regression
does not get lost, and whoever broke something finds out in a minute.
Where it is going to show up again: `uvm_object` and `uvm_component` are declared
`virtual class` in the library, so they are abstract by right. What `` `uvm_component_utils ``
does **not** do is force you to implement anything: the other way round, it *provides*
`get_type_name()` and the registry's `type_id`. The real `pure virtual` in UVM is
`uvm_subscriber::write()`, which you are going to have to write no matter what on day 4.
And in the day 2 exercise, the base class of the testbench.

---

## Polymorphism

#### *`pure virtual`: the same example, with no `$fatal` possible*

{{code:code/u3/polimorfismo/03-virtual-pura/pure_virtual.sv#trago}}

- `virtual class trago` no longer has a `servir()` that explodes: **it has no
  body**, and that is why there is nothing that can run wrong
- The commented-out line of the `top` —`trago_h = new(3)`— does not compile: an
  abstract class does not get instantiated
- If you delete `mojito`'s override, the compiler says *"Class 'mojito' extends
  'trago' but is missing implementation for 'servir'"* and that is the end of it

Note:
The point is not the `$fatal`, it is **when you find out**: without an abstract class it
explodes in the middle of the simulation, with pure virtual it does not compile.
Worth doing live: comment out `mojito`'s `servir()` and compile. The
compiler message is the one that teaches.
And the hook forward: the factory uses this to create, and the `env` for the
overrides. What today is a fernet and a mojito, tomorrow is going to be a
`base_tester` and the testers that extend it — same mechanics, another vocabulary.

---

## Polymorphism

#### *Summary of the unit*

- A `fernet` **is** a `trago`, so it fits in a `trago` variable. The
  question is **what code runs** when you call the method through that variable
- **Without `virtual` the variable rules** (*static binding*): it is decided at compile
  time, and the derived class is left ignored
- **With `virtual` the object rules**: it gets resolved during simulation, looking at what
  is inside. It is a single word and it changes everything
- The underlying idea, the one that comes back in every section that follows: **whoever
  uses the object stops being the one who picks the type**
- An **abstract class** (`virtual class`, `pure virtual`) moves the error from
  simulation to compile time: it cannot be instantiated by accident
- In SystemVerilog `virtual` is **overloaded**: virtual method, virtual
  class and virtual interface are three different things

Note:
It is the unit that unlocks the next half of the course, and it is worth saying so:
without polymorphism there is no factory, there is no `uvm_component` that can serve as a
base, and there is no override. Everything else is plumbing.
Forgetting `virtual` is also the trap of the day 2 exercise —`get_op()`
is declared without `virtual` on purpose—, so if somebody asks about it here,
do not give it away: it is understood much better by suffering it.
