<!-- es-sha: dc26f4b3f9bd -->
## Static variables

#### *The global variable you can actually defend*

- In a testbench there is always something there is **only one of**: the error counter,
  the list of in-flight transactions, the handle to the configuration
- The easy answer is a global variable, and it is the one nobody can debug
  afterwards: you do not know who wrote it, or from where, or when
- `static` is the same idea, but with a last name attached. The variable lives **in the class**, not
  in the object, and to touch it you have to name the class: `bandeja_de_fernet::vasos`
- That `::` is the whole argument. The day the value looks odd, a grep tells you
  exactly who put it there
- And it is not a loose OOP topic: the **factory** and the **`uvm_config_db`** are the
  two most important static variables of a UVM testbench

Note:
The question that orders the unit: what is there only one of in a testbench? The
factory, the configuration database, the error counter. All of that in UVM
is `static`, and that is why you write `uvm_config_db#(T)::set(...)` with a double
colon and without instantiating anything.
And the second half, which is the one you take to work: `static` solves the
"where it lives", not the "who touches it". That one is solved by `protected` plus access
methods, which is the third slide. A public `static` is a global variable
with a longer prefix.

---

## Static variables

- `bandeja_de_fernet` has no methods and no constructor: it is a class that exists **only**
  to be the place where the queue lives
- Nobody instantiates it. It gets named with the `::` operator, which tells the
  compiler *"look this variable up in the namespace of that class"*
- And there is the advantage over the global: `bandeja_de_fernet::vasos` says where it is
  declared. A loose `vasos` does not

{{code:code/u3/estaticas/01-variables/static_variables.sv#tray-and-top}}

Note:
Put plainly: static is the global variable you can actually defend in a code
review. It lives in the class, not in the object.
The second slide shows why it has to be encapsulated with static methods: if
you leave it public, the day you swap the queue for another structure you have to
touch the whole testbench.

---

## Static variables

- There is **a single** copy in memory, no matter how many objects get instantiated
- And it exists even if none gets instantiated: the `static` does not wait for the `new()`

{{code:code/u3/estaticas/01-variables/ejemplo2.sv}}

***And what about encapsulation?***
<!-- .element: class="fragment current-visible" -->

Note:
`pepe::cant` counts how many objects got created, and the detail to point out is
that **the counter exists even if there is not one object**. A `static` does not
wait for the `new()`: it is there from the moment the simulation starts. That is why it
works for counting instances, and that is why it cannot be initialized with anything that
depends on an object.
A good question to throw out: if `cant` gets incremented in the constructor, what happens
if somebody extends `pepe` and forgets the `super.new()`? It does not count. It is the same
topic as classes and extensions seen from another side.
The question on the slide is on purpose: `cant` is public, and anybody in the
testbench can write it. Leaving that discomfort hanging in the air for a while is what
makes the next slide make sense.

---

## Static variables

#### *Static methods*

- In the two previous examples the queue was out in the open, so the day it gets
  swapped for another structure you have to go and fix the whole testbench
- The version that survives a code review is two words: the variable
  `protected`, and **static access methods** that are the only door
- It is the same thing UVM does with the factory: nobody touches the type dictionary, you
  ask it with `type_id::create()`

{{code:code/u3/estaticas/02-metodos/static_methods.sv#tray-and-top}}

Note:
The difference between the two versions is two words —`protected` in front
of the queue and `static function` on the accessors— and it changes who can break what.
In the first one, any line of the testbench can `push_back` onto the
queue; in this one, only `bandeja_fernet()`.
The argument is not purism: it is that now `vasos` can be swapped for an associative
array, for a `uvm_tlm_fifo` or for whatever, without going out to fix the whole
testbench. Encapsulating is being able to change your mind later.
A syntax detail that confuses: a `static` method **cannot** touch
instance variables, only `static` ones. It makes sense —it gets called without an object,
so there is no `this`—, but the simulator's error message does not put it that way.
And the hook: UVM's `type_id::create()`, which they are going to write a hundred times
from the env on, is exactly this — a static access method to a static
structure.

---

## Static variables

#### *Summary of the unit*

- **A single copy** no matter how many objects you instantiate, **it exists even
  if you instantiate none**, and to touch it you have to name the class with `::`
- That `::` is the whole argument: the day the value looks odd, a `grep` tells you
  who put it there. But `static` solves *where it lives*, not *who touches it* —
  that one is `protected` plus static access methods
- Where it comes back: `uvm_config_db#(T)::set(...)` and `type_id::create()`, the
  two most important static variables of a UVM testbench

Note:
The hook worth leaving served: `uvm_config_db#(T)::set(...)` gets written
with a double colon and without instantiating anything, and now they know why. Same for
`type_id::create()`, which they are going to write a hundred times from the env on — it is
exactly a static access method to a static structure.
The question that orders the unit and works as a review: what is there only one of in a
testbench? The factory, the configuration database, the error counter.
All of that is `static`, and not by accident.
