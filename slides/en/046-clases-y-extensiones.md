<!-- es-sha: 038f21a96f50 -->
## Classes and extensions

#### *Why OOP in a testbench?*

- The conventional testbench is a **module**: it gets elaborated once, it exists from
  `time 0` until the `$finish`, and it is always the same one
- A stimulus looks nothing like that: it shows up, it travels through the testbench,
  it gets compared and it gets thrown away. That is not a module, it is an **object**
- Modules = *structure*, they get elaborated. Classes = *data and behaviour*, they
  get created and destroyed while the simulation runs
- And it is not optional: **UVM is a class library**. `uvm_test`,
  `uvm_component`, `uvm_object`. Without this, the rest of the course cannot be read

Note:
Here is the real wall of the course, and it is not UVM: it is OOP. Whoever arrives
from RTL has never written a class, and from the tests on everything is classes.
If the group comes from software, this unit goes fast and you gain time for
day 3. If it comes from RTL, it is the unit where you spend whatever time is
left over, even if you have to take it from somewhere else.
The question that orders everything: does this exist all the time or does it show up
and leave? The first is a module; the second, an object.

---

## Classes and extensions

#### *What a `struct` cannot do*

{{code:code/u3/clases/structs.sv}}

- The `struct` holds data and **nothing else**: the area calculation has to be written
  outside, and again in every place where it is needed
- `square_struct` has no relationship at all with `rectangle_struct`, even though a
  square is a particular case of a rectangle
- It does not randomize itself, it does not compare itself, it does not print itself

Note:
It is worth starting by asking what is wrong with the `struct`, because the spontaneous
answer is "nothing" — and they are right: for holding three fields it works perfectly. The
course is not here to say the `struct` is wrong, it is here to say where it falls
short.
The three bullets are three different things and it is worth separating them. The first one
is **cohesion**: the data is here and the operation on the data is in another file,
so nothing forces them to agree. The second is **inheritance**: a
square *is* a rectangle and the language has no way of saying so, so it gets
copied and pasted. The third is the one that gets charged on day 5: a `command_s` does not
know how to randomize itself or compare itself against itself, and all of that has to be
written outside, once for every place that uses it.
The honest punchline, so that nobody leaves with a religious idea: the `command_s` of the
conventional testbench **is** a struct, it works, and it was fine while the
testbench was a module. What changes is the scale.

---

## Classes and extensions

#### *The first class: data, methods and constructor*

{{code:code/u3/clases/rectangle_only.sv}}

- The class puts the **data** (`length`, `width`) together with **what gets done with
  it** (`area()`). The area gets computed in a single place
- `new()` is the *constructor*: it runs once, when the object gets created
- `.l(50)` is argument passing **by name**. UVM uses it all the time

Note:
The comparison with the previous slide is the whole class: the same two fields,
plus a function that used to live loose. Worth pointing at `area()` and saying that that is
the entire difference — the data and what gets done with the data travel together.
`new()` is worth presenting without mystery: it is an ordinary function, with a
reserved name, that the simulator calls on its own when the object gets created. It returns
the handle. It does nothing magic and there is no destructor on the other side.
Passing by name looks cosmetic and it is not: when the constructor has
five arguments —and `uvm_component`'s has two that are **always** the same—
`.l(50)` is what makes the call readable without going to look up the signature.
The whole of `code/` in the course is written that way.
And the question to leave hanging, the one the next slide answers: if I
declare `rectangle r;` and I never call `new()`, how many objects are there?

---

## Classes and extensions

#### *A handle and an object are not the same thing*

```systemverilog
rectangle rectangle_h;               // 1. a HANDLE. No object yet: it is null
rectangle_h = new(.l(50), .w(20));   // 2. new() creates the OBJECT and returns its handle
```

- Declaring a handle **creates nothing**. Until the `new()` it is `null`, and using it
  there blows up at simulation time, not at compile time
- The handle looks like a pointer, but it takes no arithmetic: there is no `h + 1`
- The memory of a `struct` the simulator reserves the moment it sees it; that of an
  object, only at the `new()`
- And there is no `free()`: when no handle is left pointing at it, the object gets
  collected on its own

Note:
The null pointer is THE mistake of the first week, and Verilator's message does not
help: it tells you that you dereferenced null, not where the `new()` was missing.
It is worth writing the two lines on the board and asking how many objects there
are after each one. The answer is zero and one.
This comes back twice more in the course: in the class hierarchies, when `obj1_h = obj2_h`
copies the handle and not the object; and in the tests, when the virtual interface that was
not read from the config_db is left at null.

---

## Classes and extensions

#### *Extending: `extends` and `super`*

{{code:code/u3/clases/classes.sv#rectangle-and-square}}

- `square extends rectangle` inherits `length`, `width` and `area()` **without copying
  a single line**. A square is a rectangle with a constraint, and the code says it
  that way
- The child's constructor calls `super.new()`: the top part of the object
  also has to be built, and it goes **first**
- Extending is not copying: if tomorrow `area()` changes, it changes for both

Note:
The constructor order is the first thing to nail down, because it is mandatory and
it fails ugly: `super.new()` goes **before** anything else of the child. The reason
is physical — the object is a single one, and the part the base class contributes has to
be built before touching anything. If you forget it, SystemVerilog calls it on its own
when the base constructor takes no arguments, and it does not compile when it does
take them. On day 3, `uvm_component`'s takes them.
The last bullet is the whole argument of the unit and it is worth saying with an
example: if `area()` changes tomorrow, in the `struct` version you have to remember
both places; here it changes in one and the other finds out on its own. That "finds out
on its own" is what inheritance buys you, and it is the same promise the `env` makes
to the tests on day 6.
And the warning about where this is heading, so that the word does not turn up cold on the
next slide: inheriting lets the child *use* what belongs to the parent. What still cannot
be done is for the parent to call the child's version — that is polymorphism, and it is the
section that follows.

---

## Classes and extensions

#### *Where all of this comes back*

| What you have just seen | What it is called in UVM |
| --- | --- |
| class with data and methods | `uvm_object` — the *transactions* of day 5 |
| class that also lives in the TB tree | `uvm_component` — driver, monitor, scoreboard |
| `new()` | the constructor, with `name` (and `parent` if it is a component) |
| `extends` | every test, every tester, every agent of the course |
| `super.new()` | the mandatory first line of every UVM constructor |

- One piece is missing: storing a `square` object in a `rectangle` variable.
  That is the unit that follows

Note:
Close with the table and not with the example: the student has to leave knowing that
this was not a programming detour, it was the vocabulary of the rest of the course.
The last bullet leaves the door open to polymorphism, which is the only thing
missing before a factory can be read.
And one single thing more before moving on: **declaring a handle creates
nothing**. Until the `new()` it is `null`, and using it there is the mistake that
repeats the most in the whole week. It comes back three times —here, in the tests
with the virtual interface that was not read from the `config_db`, and in the
hierarchies when `obj1_h = obj2_h` copies the handle and not the object— so it is
worth naming it all three.
