<!-- es-sha: d97533d950af -->
## Self-assessment

#### *Fifteen things you should be able to do by now · 1 of 3*

| Can I…? | Where it is |
| --- | --- |
| **1 ·** Explain why **47 %** of a verifier's time goes on debug, and what this course does about it | [Trends](libro/day1.html#trends) |
| **2 ·** Write a five-column **verification plan** for a DUT I have not seen before | [The verification plan](libro/day1.html#the-verification-plan) |
| **3 ·** Say why **100 % code coverage** does not mean the DUT is verified | [Functional coverage](libro/day1.html#functional-coverage) |
| **4 ·** Say what to look at **first** when a `covergroup` reports 0 % | [Functional coverage](libro/day1.html#functional-coverage) |
| **5 ·** Explain which race a `clocking block` avoids — and why they are **optional** anyway | [Interfaces and BFM](libro/day1.html#interfaces-and-bfm) |

Note:
This rubric is for the student, not for the instructor, and it is worth saying so:
nobody grades it. It is good for two different moments —before the exam, as a study
guide; and right now, as a diagnosis— and the instruction is the same in
both: read the statement and ask yourself *"can I explain it to somebody?"*, not
*"does it ring a bell?"*. The difference between the two answers is the whole course.
Every row links to the section of the **book**, which is the version to read straight
through, with the instructor note inside the text. A "no" is not bad
news: it is a link.
If it is being taught in class, project the three slides and ask for hands per row. The three
that get the most hands are the ones to review, and that measurement is worth more than
the complete review.

---

## Self-assessment

#### *Fifteen things you should be able to do by now · 2 of 3*

| Can I…? | Where it is |
| --- | --- |
| **6 ·** Extend a class and change its behaviour **without copying it**, and say what `super` does | [Classes and extensions](libro/day2.html#classes-and-extensions) |
| **7 ·** Change the class a testbench uses **without touching the `env`**, with a `set_type_override` | [The factory pattern](libro/day2.html#the-factory-pattern) |
| **8 ·** Explain why a UVM simulation **ends at t=0** if nobody raises an objection | [Tests](libro/day3.html#tests) |
| **9 ·** Say why `build_phase` runs top down and `connect_phase` the other way round | [Components and phases](libro/day3.html#components-and-phases) |
| **10 ·** Make a scoreboard that fails say **something more** than "it failed" | [Reporting](libro/day3.html#reporting) |

Note:
The 8 and the 9 are the two most often answered with a *"it rings a bell"*: they are mechanics of
the library and they are understood by looking, until the day you have to debug a
testbench that finishes without having sent any stimulus. If the student hesitates on
either of the two, the Tests section is half an hour and closes them.
The 10 is the one that pays off most in the long run and the one most underestimated. The whole course
points at the 47 % of row 1: a `uvm_error` that prints *"FAIL"* leaves whoever is
debugging exactly where they were, and one that prints the transaction, the
prediction and the time saves them half a morning. It is the difference between a
testbench that works and one you can work with.

---

## Self-assessment

#### *Fifteen things you should be able to do by now · 3 of 3*

| Can I…? | Where it is |
| --- | --- |
| **11 ·** Hang a new subscriber off an analysis port **without touching the one publishing** | [A single place that watches the wire](libro/day4.html#a-single-place-that-watches-the-wire) |
| **12 ·** Write a constraint that reaches a corner case, and **measure** whether the `dist` does what it says | [Constrained random](libro/day5.html#constrained-random) |
| **13 ·** Say what an agent with `is_active = UVM_PASSIVE` builds and what it does **not** | [Agents](libro/day6.html#agents) |
| **14 ·** Explain why a `uvm_sequence` **does not show up** in `print_topology()` | [Sequences](libro/day6.html#sequences) |
| **15 ·** Write a property that sees a protocol violation, and say why `--assert` is not optional | [Assertions (SVA)](libro/day7.html#assertions-sva) |

- All fifteen? Then what is left is the **capstone**: an APB slave, its
  spec, and the whole testbench from a blank sheet

Note:
The 14 is the question thrown out on day 3, when the UVM class diagram
shows up, and it gets answered on day 6. If the student can answer it, they understood the
division that explains half the library: `uvm_object` is the **data** and
`uvm_component` is the **structure**. An object gets created and thrown away; a component
gets built once and lasts the whole simulation.
The 12 says *measure*, not *write*, and it is on purpose: the exercise `d5b` exists
because a `dist` with the weights properly set can give a histogram that lies,
and whoever never measured it has no way of knowing.
And the last line is the only honest thing that can be said about the fifteen: they are
a necessary condition, not a sufficient one. What proves somebody knows how to do this is
a testbench of their own working, and that is the capstone. A student who ticks all
fifteen and does not finish it did not finish the course.
