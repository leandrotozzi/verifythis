<!-- es-sha: 356adbed7c4a -->
## The factory pattern

#### *Who decides the type?*

- Every `new()` you write is a **hardcoded** decision: that line is always going
  to build that class, and to change it you have to edit it and recompile
- In a testbench that does not scale. You want the same `env` sending additions today and
  multiplications tomorrow, picked from the command line
- The parameterized classes of the previous unit are not enough either: the `#(...)` gets
  resolved at compile time, and here the decision has to happen **at runtime**
- The factory is the answer: instead of building it yourself, you **ask** for the object
  from somebody who knows which type to hand over
- It is the most visible pattern of UVM, and with it you understand `type_id::create()` and
  `set_type_override()`, which are going to be in every file of the rest of the course

Note:
The sentence that orders the unit: **whoever uses the object stops being the one who picks
the type**. Everything else is implementation detail.
It is worth saying up front where this ends, because otherwise it looks like a programming
detour: the `+UVM_TESTNAME=add_test` of the tests, tomorrow, is going to be a factory —
UVM reads a string from the command line and builds the class that corresponds.
Here you see the mechanism from the inside.
And for whoever comes from software: yes, it is the GoF Factory Method, and we
invented nothing. The Python version on the last slide is there precisely for that.

---

## The factory pattern

- A design pattern, not a language feature: a class whose only job
  is to **build objects for you**
- You ask it for an object by describing which one you want —a string, an enum— and it
  hands it back already built, of whichever subtype corresponds
- Before the solution, the problem. Look at what happens when the `new()` is
  written in the place where the object gets used:

{{code:code/u3/factory/without-factory.sv}}

> *The idea is to create data of random types without changing the code.*

Note:
The problem first, the pattern after: I want to change the type of object that gets
created without touching the code that creates it. With that in your head, UVM's factory
—the env— is the same idea wrapped in macros.
The Python version is next to it on purpose: it shows whoever comes from software
that we invented nothing.

---

## The factory pattern

![UML Class Example Diagram](res/diagrams/en/factory_diagram.svg)
<!-- .element: class="grande" -->

<br>

- **The factory** is the method at the top: it takes an argument and returns an object
  of the type that argument asks for
- **Polymorphism** is what makes it possible: `fernet` and `mojito` extend
  `trago`, so both fit in a `trago` variable
- Without the second there is nowhere to put what the first returns. They are the two
  halves of the same tool

Note:
The factory **does not work without polymorphism**, and it is worth saying it
that way: if `hacer_trago()` could not return a `fernet` stored in a `trago`
variable, there would be nothing to manufacture. They are the two halves of the same thing.
The useful question about the diagram: what type is the thing `hacer_trago()`
returns? `trago`, always. What changes is which object comes
inside. The caller never finds out, and that is exactly the point.
And the limit you see right away: if the caller needs something only `fernet` has
—the `sin_hielo` of the example— the comfort is over and you have to cast.
That is the next slide, and it is the reason UVM's factory is better than
this one.

---

## The factory pattern

- `virtual` is enough as long as you use methods the base class already declares. But
  `fernet` adds a field of its own —`sin_hielo`— that `trago` knows nothing about
- To reach it you have to bring the handle down to its real type, and that is `$cast`:
  it converts the variable of the second argument to the class of the first
- It checks **at runtime** and returns 0 if it does not work, so it never goes alone: always
  inside an `if` with its `$fatal`

{{code:code/u3/factory/factory.sv#cantina}}

- And `$cast` in use, in the `top`: the factory always returns a `trago`, and
  to reach `sin_hielo` you have to bring it down to `fernet`

{{code:code/u3/factory/factory.sv#casting}}

Note:
Two things about this code, and both come back in UVM.
The first: `$cast` **checks at runtime and returns 0**, it does not abort. That is why in the
example every call goes inside an `if (!$cast(...)) $fatal(...)`. A `$cast`
without a check is the `assert(randomize())` of the transactions in another disguise: if
it fails, you carry on with a handle at `null` and the error shows up three lines later, in
another place.
The second: look at the `case (pedido)` of `hacer_trago()`. To add a new drink
you have to **edit the factory**. In other words we took the hardcoding out of whoever uses it
and put it in a single place — better, but it is still there.
There is what UVM solves, and it is worth saying so: `` `uvm_component_utils ``
registers the class **on its own**, so UVM's factory has no `case` to
maintain, and `type_id::create()` returns the right type without anybody casting.
Both annoyances of this slide disappear in the env.

---

## The factory pattern

#### *Python Style*

{{code:code/u3/factory/factory.py#factory-class}}

- The same factory, in a language that has nothing to do with hardware: a
  static method with an `if` per type and a `raise` for what does not exist
- And the same annoyance: adding a drink forces you to **edit the factory**
- The whole file is in `code/u3/factory/factory.py` and it runs with `python3`:
  it generates twenty drinks at random and serves them all the same way

Note:
It is there on purpose and the moral is short: this is not a verification oddity,
it is a design pattern from 1994 that in Python takes ten lines.
The bottom part of the file is worth opening if there is time left: `Trago.__subclasses__()`
asks the language which classes inherit from `Trago`, and with that the generator no
longer needs a hand-written list. It is exactly what UVM's factory registration does
with `` `uvm_component_utils ``, but from the top down instead of
each class signing itself up.
The punchline: the final loop treats the twenty drinks the same, without asking what
type they are. That is polymorphism, and it is what makes a factory
worth anything.
The slide works for two opposite audiences. For whoever comes from software it lowers
the suspicion —"ah, it is the same old factory"—. For whoever comes from RTL it shows
that what they are learning is not "weird SystemVerilog stuff": it is
programming, and you can go and read about it outside the EDA world.

---

## The factory pattern

#### *Summary of the unit*

- Every `new()` you write is a **hardcoded decision**: that line always
  builds that class, and changing it means editing and recompiling
- Parameterized classes are not enough: the `#(...)` gets resolved **at compile time**, and
  here the decision has to happen **at runtime**
- The factory inverts who is in charge: instead of building, you **ask** for the object from
  somebody who knows which type to hand over
- **It does not work without polymorphism**: both halves are needed —
  somebody who manufactures and a base variable to store it in
- **`$cast` checks at runtime and returns 0**, it does not abort. That is why it never goes
  alone: always inside an `if` with its `$fatal`
- The annoyance that is left —the `case` you have to edit to add a type— is exactly
  the one UVM solves: `` `uvm_component_utils `` **registers the class
  on its own**

Note:
Closing of the most abstract section of day 2, and it is worth landing it with what
is coming: the `+UVM_TESTNAME=add_test` of the tests **is a factory** —
UVM reads a string from the command line and builds the class that corresponds.
Here they saw the mechanism from the inside, a day early.
The sentence that sums up the whole section: **whoever uses the object stops being the
one who picks the type.** Everything else is implementation detail.
And for whoever comes from software: it is the GoF Factory Method, from 1994, and in
Python it takes ten lines. We invented nothing, and that is good news.
