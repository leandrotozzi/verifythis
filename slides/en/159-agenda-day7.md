<!-- es-sha: af83e0b2c500 -->
<!-- .slide: id="day7" -->

## Yesterday we left…

#### *Where the testbench stands*

- The testbench was left **reusable for one agent**: agents with `is_active`, the
  analysis in the `env`, and the stimulus outside the tree, in sequences. The last
  piece —coordinating two— is this morning
- No line of the test names a component from inside the `env`: the last one went
  with the `default_sequence` through `uvm_config_db`
- And the other half of the verification plan is missing: the rows **no
  scoreboard can close**, because they are not about the result but about the
  protocol

Note:
The day 7 recap works as a hinge, and it is worth saying the two things it is
made of: this morning UVM gets closed —the virtual sequence is the last piece,
and with it the testbench of the course is whole— and this afternoon opens what
UVM does not solve, which is the other half of the plan.
The third bullet is the arc planted on day 1 with the verification plan and left
open on purpose: the scoreboard checks **what**, the assertion checks **how**.
Today it closes.

---

<!-- .slide: data-machete="res/diagrams/en/assertions_property.svg|Anatomy of a property: label · clock · guard · antecedent · implication · consequent and action,res/en/machete-debug.svg|Debug cheat sheet: the seven knobs of the course and what to look at for each symptom" -->

## Agenda

#### *Day 7 · ≈ 5 h 15 · unit 8 · the other half*

- Warm-up: five seeds and a merge, with `make regresion`
- Virtual sequences: the last piece of the reusable testbench
- Assertions (SVA)
- The capstone: an APB testbench, from scratch
- From the VTALU to a real bus
- The debug toolbox · The 21 silent traps
- Glossary, references and wrap-up
- Self-assessment: fifteen things you should be able to do by now
- *On Monday*: what to do with this once the screen goes off

*And afterwards, **day 8**: optional, and for whoever has already handed in the capstone*

**By the end of the day you can:**

- **Write** a property that sees a protocol violation, and say why `--assert` is
  not optional
- **Coordinate** two interfaces from a single virtual sequence
- **Hand in** a whole testbench for a DUT you have not seen before

Note:
The morning has three pieces and the order matters: the seed warm-up is ten
minutes without SystemVerilog and it hooks into the `make regresion` the capstone
is going to ask for; the virtual sequences close UVM; and SVA opens the other
half of the plan. The afternoon is the capstone.
The third objective is the one the course is worth, and it is honest to put it as
an objective of the day even if the hand-in comes later: in a company format the
capstone is handed in the next day, and in a term it goes to the exam period.
What gets done this afternoon is starting it with the instructor next to you,
which is when it pays off the most.
