<!-- es-sha: ff2e67a23c5a -->
## Copying an object that contains another

#### *The handle is not the object*

- From the transactions on, the testbench data stops being a `struct` and becomes
  **objects that travel**: the monitor creates them, the scoreboard compares them
- And there a problem appears that a `struct` did not have. A `struct` gets copied
  when you assign it; an object does **not**: `obj1_h = obj2_h` copies the handle,
  not the data
- Which means two parts of the testbench can be looking at the same object without
  knowing it. If one modifies it, the other sees the change halfway through
- Copying it for real has to be written, and written **at every level of the
  hierarchy**, or the fields from above get lost in silence
- This section is the OOP that is missing so that the transactions can be copied,
  compared and printed without lying

Note:
It is an OOP section in the middle of UVM, and it is worth saying why it is here
and not on day 2: because only now is it needed. Up to reporting —the closing of
day 3— the data was a `struct` and copied itself.
The bug in the second bullet gets written by everybody once, and the symptom is
horrible: you send a transaction to the scoreboard, you go on using the same
handle for the next one, you modify it, and the scoreboard compares against data
that changed after it received it. It does not fail every time, and when it does
it looks like a DUT bug.
The other half —the `super` at every level— has a different and more treacherous
symptom: the day somebody puts a new class in the middle of the hierarchy, the
`convert2string()` stops printing half the fields and **nobody finds out**,
because it goes on printing something.
The question to start with: if `handle_a = handle_b`, how many objects are there?
One. It is the same question as in classes and extensions, now with consequences.

---

## Copying an object that contains another

#### *Never duplicate code*

> "If we find ourselves copying code and making small modifications to it inside our program, we are doing things wrong. Code must never be duplicated."

In OOP, instead of copying code...
<!-- .element: class="fragment grow" -->

***we extend classes***
<!-- .element: class="fragment current-visible" -->

---

## Copying an object that contains another

#### *`convert2string()`: the problem*

![The four levels of the hierarchy](res/diagrams/jerarquias_convert2string.svg)
<!-- .element: class="grande" -->

- The hierarchy goes from the general to the particular, and each class adds
  fields of its own
- We want two things from it: to be able to **copy** a whole object and to
  **print** it whole, without anything from the levels above getting lost
- This first version works. Count how many times the name of a field of the base
  class shows up

{{code:code/u6/jerarquias/pre_convert2string.sv}}

Note:
This version works, and that is the problem: it looks fine and it is wrong. Every
`convert2string()` prints every field by hand, including the ones it inherited.
Go to the `$sformatf` of the bottom-most class and count how many times the name
of a field of the class above is repeated. Every one of those repetitions is a
line you have to remember to touch the day a field gets added.
The question that sets up the next slide: what happens if tomorrow somebody puts
a new class **in the middle** of the hierarchy? The ones below go on printing
what they knew, the one in the middle does not show up, and there is no error.
The method still returns a string.

---

## Copying an object that contains another

#### *`convert2string()`: the deep version*

![The deep copy, level by level](res/diagrams/jerarquias_convert2string_deep.svg)
<!-- .element: class="grande" -->

- The day somebody puts a class **in the middle**, the ones below go on printing
  what they knew and the one in the middle does not show up. And there is no
  error: the method still returns a string
- The rule that fixes it: each class prints **only what is its own** and asks
  `super` for the rest
- Nobody knows what is further up, so inserting a level breaks nothing

{{code:code/u6/jerarquias/pre_convert2string_ok.sv}}

Note:
The rule, short: **every method of the hierarchy takes care only of its own
fields and asks `super` for the rest.** Nobody knows what is further up, and that
is why inserting a class in the middle breaks nothing.
The pattern repeats in the same way in the three methods of the section
—`convert2string()`, `do_copy()`, `do_compare()`— and in the three of UVM too. If
you get into the habit of writing the call to `super` **first**, before touching
your own fields, you never forget it.
It is worth pointing out the parallel with something they have already seen: it
is exactly the same argument as the `super.new()` of classes and extensions. The
top part of the object has to be built too — and it also has to be printed,
copied and compared.

---

## Copying an object that contains another

#### *The equals sign copies nothing*

- `obj1_h = obj2_h` **copies nothing**: it leaves two handles pointing at the same
  object
- If you modify it through one, the other sees it. There is no notice, there is no
  warning
- With a `struct` that did not happen: it gets copied when you assign it. It is
  the difference to keep in mind from here to the end of the course

Note:
It copies the handle, not the object. It is the bug everybody writes once: you
modify the transaction you already sent to the scoreboard and the scoreboard sees
the change halfway through. This is where the clone() of the transactions comes
from.

---

## Copying an object that contains another

#### *Copying for real is two steps*

Copying for real is two steps, and they have to be written: **instantiate** a new
object and **hand it the data** field by field

{{code:code/u6/jerarquias/pre_copy.sv}}

- The `new()` is the first step and it is not optional: without a new object on
  the other side, there is nowhere to copy to
- The second step is by hand, field by field. SystemVerilog has no built-in deep
  copy
- And field by field means **the fields of the classes above too**, which is
  exactly what gets forgotten

Note:
It is worth making the comparison with the assignment of the previous slide out
loud: `a = b` is one line and copies nothing; copying for real is two steps and
both have to be remembered.
That the language does not bring a deep copy is not an oversight by the
committee: there is no general answer. If the class has a handle to another
object, do you copy the handle or the object? It depends, and that is why you
have to decide it yourself in every `do_copy()`.
It is exactly the same dilemma the transactions are going to have if some day
they carry an array of objects inside. In this course it does not happen, but it
is worth leaving the question on the table.

---

## Copying an object that contains another

#### *`do_copy()`: each class touches what is its own*

*do_copy():* Every class in the hierarchy has to call its parent class, and therefore every do_copy() method needs the same type of argument. But we have different classes... We use *polymorphism*

{{code:code/u6/jerarquias/pre_copy2.sv#fernet_con_hielo}}

Note:
Here is the detail that looks bureaucratic and is not: **every** `do_copy()` of
the hierarchy takes an argument of the **base** class, not of its own. If each one
took its own type, the call to `super.do_copy(rhs)` would not compile — the types
would not match.
The price is that inside every method you have to `$cast` in order to read your
own fields. And as we saw in the factory, that `$cast` checks at run time: if
somebody tries to copy a `mojito` onto a `fernet`, it returns 0 and it has to be
caught.
It is the first time a signature convention shows up that exists only so that
polymorphism can work. In UVM it is going to be the same and with more rules: the
argument has to be a `uvm_object` —and by convention it is called `rhs`—,
`do_compare()` also takes a `uvm_comparer`, and so on. When those signatures show up in the transactions, the answer to "why like
this?" is this slide.

---

## Copying an object that contains another

#### *Summary: the terrible solution*

{{code:code/u6/jerarquias/wrong.sv#fernet_con_hielo.convert2string}}

- It is the `convert2string()` of `fernet_con_hielo`, the bottom-most class: it
  prints **all four fields by hand**, including the three it inherited
- It works, and that is why it is dangerous. The day `fernet` gains a field, this
  method goes on compiling and goes on printing — less than it should
- The whole file is in `code/u6/jerarquias/wrong.sv`. The three `do_copy()`s in
  there do call `super`; the one with the vice is `bad_copy()`, at the very bottom

Note:
The rule to leave behind: **a class only writes on its own fields.** Everything
else it asks `super` for.
It is worth counting on screen: `hielos` and `con_coca` show up in four different
`convert2string()` of this file. Four places to remember, and not one of them
fails if you forget one.
There is a `bad_copy()` a little further down the file worth opening if there is
time to spare: it takes a `fernet_con_hielo` as an argument instead of a `trago`.
It compiles and it works... until somebody calls it through a handle of the base
class, and there no polymorphism can help.

---

## Copying an object that contains another

#### *Summary: the deep solution*

{{code:code/u6/jerarquias/deep.sv#convert-and-copy}}

- The same two methods, written the way they should be: each one calls `super` and
  then touches **a single field**, its own
- `convert2string()` **concatenates** what the one above returned; `do_copy()`
  **calls the one above first** and then copies what is its own
- With that shape, putting a new class in the middle of the hierarchy works on its
  own: the chain of `super` includes it without anybody editing anything

Note:
Closing of the section, and it is worth saying where all of this is going: the
three methods they have just written by hand are **exactly** the three UVM asks
for in a transaction. `do_copy()`, `do_compare()` and `convert2string()`, with
the same rules about `super` and `$cast`.
The difference is that in UVM they do not get called directly: you write
`do_copy()` and the testbench calls `copy()`, which is the one that lives in
`uvm_object` and takes care of the rest. Same idea as the phases — you write the
bottom part, the library handles the protocol.
And the question to walk out of the day with: if writing this properly costs
three methods per class, why does nobody generate it? Somebody does: they are the
`` `uvm_field_* `` macros. The course does not use them, and the reason is on the
`super.build_phase()` slide of the components — they generate hundreds of lines
nobody reads and that show up in the stack when something fails. Read them yes,
write them no.

---

## Copying an object that contains another

#### *Summary of the unit*

- `obj1_h = obj2_h` **copies nothing**: it leaves two handles pointing at the same
  object. If you touch it through one, the other sees it, and there is not even a
  warning
- With a `struct` that did not happen —it gets copied when you assign it—, and
  that is the difference to keep in mind until the end of the course
- **Copying for real is two steps**: instantiate a new object and hand it the
  data. That is where the `clone()` of the transactions comes from
- In a hierarchy, each class has to touch **a single field, its own**, and call
  `super`. Writing the four fields by hand is the terrible solution
- For that to work, the `do_copy()` / `do_compare()` all take **the same type of
  argument**, the base class. It is polymorphism, once again
- The day somebody puts a class **in the middle** of the hierarchy, the deep
  version goes on working by itself. The other one you have to go out and fix

Note:
The handle bug is the one everybody writes once: you modify the transaction you
already sent to the scoreboard, and the scoreboard sees the change halfway
through. It does not fail at the time; it fails later, and somewhere else.
The short way to close: **the `=` copies the slip of paper with the address, not
the house.** And that is why UVM brings `copy()`, `clone()` and `compare()`
ready-made — which is exactly the unit that follows.
