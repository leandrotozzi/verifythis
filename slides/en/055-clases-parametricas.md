<!-- es-sha: c0af6402e191 -->
## Parameterized classes

#### *It is not a class: it is a mould*

- The `bandeja_de_fernet` of the previous section works for fernets. For mojitos you have to
  write another one just like it, with one word changed
- You already solved that in RTL and you do not call it OOP: a FIFO does not get copied for
  every data width, it gets parameterized. `#(.awidth(8), .dwidth(16))`
- A parameterized class is the same thing, with **types** instead of numbers:
  `bandeja #(fernet)` and `bandeja #(mojito)`
- And there is a consequence that surprises: every different `#(...)` is a **different
  class**, generated at compile time. They share nothing, not even the `static`
- Why it matters: every `#(...)` you see in the rest of the course is this.
  `uvm_analysis_port #(T)`, `uvm_subscriber #(T)`, `uvm_sequence #(T)`

Note:
Starting from Verilog's `parameter` is deliberate: the RTL student already knows how to
parameterize, only with widths. Here the parameter is a type, and the rest is
the same.
What has to be left crystal clear before moving on is the third bullet, because
it is question 6 of the review and because it is the base of all of UVM:
`bandeja#(fernet)` and `bandeja#(mojito)` are **not the same class with a
different field**. SystemVerilog generates a whole class for every combination of
parameters, at compile time. That is why each one has its own `static` queue.
The short way of saying it: the parameterized class is not a class, it is the recipe
for manufacturing classes. The class appears when you write the `#(...)`.
And a limit worth naming now so that it does not surprise them: since it gets
resolved at compile time, the type has to be known there. You cannot pick the
parameter at runtime. Picking at runtime is what the factory solves, which is the
unit that follows.

---

## Parameterized classes

- Before the new syntax, the parameter you already know: a RAM that does not get
  copied for every width, it gets instantiated with `#(.awidth(8), .dwidth(16))`
- Every instantiation with different parameters produces **different hardware**, and
  nobody argues about it
- *Parameterized class definitions* are that same thing on the software side, with
  one difference: the parameter can be a **type**

{{code:code/u3/parametricas/01-memoria/pres-ch8.sv}}

Note:
It is worth saying what we are going to use them for, otherwise it looks like a loose OOP
topic: `uvm_analysis_port#(T)`, `uvm_subscriber#(T)`, `uvm_tlm_fifo#(T)`. Every `#(...)`
that shows up in the rest of the course is this.

---

## Parameterized classes

- Version with static methods: the tray does not get instantiated, you ask it with `::`
- The queue is `static` and even so there are **two**: `bandeja#(fernet)` and
  `bandeja#(mojito)` are two different classes, each one with its own

{{code:code/u3/parametricas/02-estatica/bandejas.sv|lines=53-91}}

Note:
This is the slide where the mould thing gets demonstrated, and it is worth doing it by
running the example: two fernets and two mojitos go in, and each `lista_tragos()` prints
only its own. The queue is `static` and even so there are two.
The question for the board: how many queues are there in memory? Two. And how many
would there be with three drinks? Three. Every `bandeja#(X)` the compiler sees in
the code generates its class, with its own `static`. The ones nobody uses do not exist.
A detail that always gets asked: `T` is not declared anywhere as
"trago or derivatives". SystemVerilog has no such constraint — the check is
by use. If you put in a type that has no `get_name()`, the error shows up when
compiling the specialization, not when declaring the class, and the message points
inside `bandeja`. It is confusing the first time.

---

## Parameterized classes

#### *Variables with parameters*

- Here the tray gets instantiated like any object and you have to have the handle to
  use it — it stops being visible from the whole testbench
- It does exactly the same thing as the previous version. What changes is the scope,
  and that is the decision: **`static` when there really is only one, instantiated
  when there can be more than one**

{{code:code/u3/parametricas/03-instanciada/bandejas.sv|lines=48-76}}

Note:
The two versions do exactly the same thing and the difference is one of design, not of
syntax: in the previous one the tray is global —anybody in the testbench sees it—; in
this one you have to have the handle to be able to use it.
The rule you take to work: **static when there really is only one in the
whole testbench, instantiated when there can be more than one**. And when in doubt,
instantiated: it is easier to add a second object than to take the `static` off
something half the testbench already uses.
With that in hand, place UVM: the `uvm_config_db` is static because there is only
one. A `uvm_analysis_port#(command_transaction)` is instantiated because each
monitor has its own. The student already has the criterion to read both.

---

## Parameterized classes

#### *Summary of the unit*

- It is the `parameter` of RTL you already know, but the parameter can be a
  **type**: `bandeja #(fernet)` instead of `#(.dwidth(16))`
- A parameterized class **is not a class**: it is the recipe for manufacturing classes.
  The class appears when you write the `#(...)`
- And every different `#(...)` is a **different class**, generated at compile time.
  They share nothing — **not even the `static`**
- The criterion you take to work: **`static` when there really is only one,
  instantiated when there can be more than one**. When in doubt, instantiated
- The limit: it gets resolved **at compile time**, so the type has to be known
  there. Picking at runtime is the unit that follows
- Every `#(...)` in the rest of the course is this: `uvm_analysis_port #(T)`,
  `uvm_subscriber #(T)`, `uvm_sequence #(T)`

Note:
The bullet about the different classes is the one to leave nailed down, because it is
the review question and because it is the base of all of UVM. `bandeja#(fernet)` and
`bandeja#(mojito)` are not the same class with a different field: they are two
whole classes, each one with its own `static`.
And the last bullet places the section: the `uvm_config_db` is static because there is
only one; a `uvm_analysis_port#(command_transaction)` is instantiated because
each monitor has its own. With that they can already read both.
