<!-- es-sha: 4659d324cac3 -->
## Introduction

#### *What is UVM?*

- **U**niversal **V**erification **M**ethodology: a **class library**
  written in SystemVerilog, plus a pile of **conventions** on how to use it
- It is not a language and it is not a simulator. Everything we are going to see in the
  course can be written by hand — and on days 1 and 2 we are going to write it by hand
- It is made by **Accellera**, the same consortium that standardized SystemVerilog, and it is
  **IEEE 1800.2**. The course uses the reference implementation, `uvm-core
  2020.3.1`
- It comes from OVM (Cadence + Mentor), with ideas from VMM (Synopsys) and from eRM
  (Verisity): the methodologies of three vendors that competed, until the
  industry got tired of translating testbenches between tools
- And there is the goal, and it is a single one: **that the testbench of the person next to
  you looks like yours**

Note:
The sentence that orders the section is the one in the second bullet, and it is worth saying
it loudly because it lowers the anxiety of whoever arrives scared: **UVM does nothing you
could not do yourself**. There is no magic inside. There is a factory, some ports, some
phases and a lot of agreement about names.
If somebody asks why bother then: because of the last bullet. A
verifier who changes project —or company— opens the testbench and recognizes
the structure on day one. That is what you are buying. It is not simulation
speed and it is not fewer lines: it is that the structure is the same everywhere.
The historical note is useful for whoever comes from the industry: until 2011 every
vendor had its own, and porting a testbench from VMM to OVM meant rewriting it. UVM
exists because that was unsustainable, not because somebody had a better idea.
And one clarification that avoids a classic misunderstanding: *Open Source* here means
that the **library** is free (Apache 2.0). The **simulator** that runs it almost
always is not — except in this course, which is what all of this is about.

---

## Introduction

#### *Where it comes from*

![From eRM, VMM, AVM and OVM to UVM](res/originUVM.svg)
<!-- .element: class="grande" -->

Note:
The diagram in one sentence: six acronyms from four vendors that converge. eRM was
Verisity's (the `e` language), RVM and later VMM Synopsys', AVM Mentor's and URM
Cadence's; OVM merged AVM with URM, and it is the base UVM came out of.
What has to be pointed out is the date at the bottom and the jump it means: UVM 1.0 is
from 2011, which means this is **young**. Somebody with fifteen years of career today
started before it existed.
And the moral that gets used for the rest of the course: when they find code with
`ovm_component` instead of `uvm_component`, it is not a typo — it is a
testbench from before 2011 that nobody migrated. It happens more than it seems.

---

## Introduction

#### *A SystemVerilog testbench, from the inside*

![Anatomy of a SystemVerilog testbench](res/TB.svg)
<!-- .element: class="grande" -->

Note:
This is the testbench **we** are going to write, by hand, on days 1 and
2. It is worth saying it like that: the boxes in this diagram are not theory, they are the
files that are going to be open today.
Point at the generator, the driver, the monitor and the checker, and make the point that
none of those names is UVM's: they are the names anybody gives to the pieces of a
testbench, in any language. UVM did not invent them; it standardized them.

---

## Introduction

#### *The same testbench, with UVM structure*

![The same testbench with UVM structure](res/TB_UVM.svg)
<!-- .element: class="grande" -->

Note:
It is worth staying here a while: this diagram is the map of the rest of the course.
Point at driver, monitor, scoreboard and sequencer, and say that each one is going to be
a section. By the end of day 5 the student is going to have everything except the sequencer,
which is day 6.
The comparison worth making live is against the previous diagram: **they are
the same boxes**. What UVM adds is the tree that contains them, the ports
they talk through and the phases that build them in order. Nothing else, and that is
not little.

---

## Introduction

#### *The class tree*

![UVM base class tree](res/uvm_class_diagram.svg)
<!-- .element: class="grande" -->

Note:
This diagram is scary and that is why it is worth defusing it right away: **out of all of
this we are going to use seven classes**. `uvm_object`, `uvm_component`, `uvm_test`,
`uvm_env`, `uvm_agent`, `uvm_driver`, `uvm_monitor` and `uvm_sequence` — all right,
eight.
What does have to be marked is the split at the top, because it explains
half the course: hanging off `uvm_object` is the **data** —the transactions, the
sequences, the configs— and hanging off `uvm_component` is the **structure** —everything
that lives in the tree and has phases—. An object is created and thrown away; a component
is built once and lasts the whole simulation.
The question to throw at the group when we get to agents: is a
`uvm_sequence` an object or a component? An object. And that is why it does not show up in
`print_topology()`.
It is the same diagram that is in the cheat sheet, top right, to look at again
when needed.

---

## Introduction

#### *Run more tests writing less code*

- That is the promise, and it has one condition: **the env and the components barely
  change** from one test to another. What changes is the stimulus
- For that to work, the testbench has to leave **hooks**: virtual
  methods, the factory and callbacks. A test hooks in there and does not touch
  the structure
- A new test is then one of these three things, and none of them touches the env:
  - adding **constraints** to reach a corner case
  - doing a factory **override** to swap one class for another
  - injecting errors or delays with **callbacks**
- And on top of all that, the lever that pays off the most: **the same test with hundreds of
  different seeds**

Note:
This is the slide you have to be able to repeat at the end of the course, because it is the
whole thesis. And it is worth being honest: *"run more tests, write less code"* is a vendor
slogan, but the verifiable part is true and you can point at it with your finger on
day 6 — the `add_test` of the sequences is **two lines**, and it changes the whole
stimulus without touching a single class of the env.
The order of the three hooks is not accidental, it goes from smallest to largest: a constraint
changes values, an override changes a class, a callback changes behaviour
at one point of the class that already exists. All three are a section of the course —*Constrained
random* on day 5, *The factory pattern* on day 2 and *Callbacks* on day 6—, so
this slide can be put up three more times.
And the last line is the most underestimated one. A test with a thousand seeds is not
"the same test a thousand times": it is a thousand different scenarios for the price of writing
one. It is literally the `d6-semillas` exercise of day 6.
