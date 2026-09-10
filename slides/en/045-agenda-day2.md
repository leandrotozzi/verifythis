<!-- es-sha: 9c1de2f54dcf -->
<!-- .slide: id="day2" -->

## Yesterday we left…

#### *Where the testbench stands*

- A testbench that **works**: it sends stimulus, checks the result and measures
  functional coverage. The verification plan says which row each thing closes
- The BFM took the signals inside an `interface`, and the testbench went on to
  call `send_op()` instead of moving wires
- And one problem was left open: **changing the stimulus means editing the
  file**. A tester that only multiplies is copying the one that is there and
  deleting five lines

Note:
Thirty seconds, and they are not filler: day 2 is the most abstract of the course
and it starts without touching the VTALU all morning. The student has to walk in
knowing this is the answer to something that already happened to them yesterday.
The bullet to underline is the third one, because it is the problem the whole
unit solves. If the group comes from a previous class, it is enough to ask *"how
did you make a tester that only multiplies yesterday?"* and wait for the answer
—copy and delete— before moving on to the agenda.
If it is taught on video, this is the slide that replaces the week of distance
between one chapter and the next.

---

<!-- .slide: data-machete="res/diagrams/en/uml-poli.svg|trago, fernet and mojito: which servir() lives in which class,res/diagrams/en/factory_diagram.svg|cantina builds fernet and mojito, and returns a trago handle" -->

<!-- .slide: data-transition="concave" -->

## Agenda

#### *Day 2 · ≈ 4 h · unit 3 · the OOP UVM takes for granted*

- Classes and extensions
- Polymorphism
- Static variables and methods
- Parameterized classes
- The factory pattern
- A testbench without a single module

**By the end of the day you can:**

- **Extend** a class and change its behaviour **without copying it**, and say
  what `super` does
- **Change** the class a testbench uses **without touching** the code that uses
  it, with a factory
- **Write** the day 1 testbench without a single module

Note:
Day 2 is the only one that does not touch the VTALU all morning, and that is why
it is worth putting the three verbs up front: they are the answer to *"what is
this for?"*, which is the question that shows up half an hour in.
The third one is the one that closes the day and the one practised in the
exercise. The first two are rows 6 and 7 of the closing self-assessment.
