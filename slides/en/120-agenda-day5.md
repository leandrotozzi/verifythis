<!-- es-sha: c06c1cebd8c5 -->
<!-- .slide: id="day5" -->

## Yesterday we left…

#### *Where the testbench stands*

- The monitor **publishes** and knows nobody: the scoreboard and the coverage
  hang off it, and adding a third does not touch the one that publishes
- The TLM FIFOs settled who waits for whom, and `fork`/`join` who runs with whom
- But the data is still **three loose fields**: `A`, `B` and `op` travel
  separately, they get copied by hand, and comparing them means writing the whole
  comparison

Note:
The day 5 recap has to install the discomfort of the loose data, because that is
what justifies a whole unit about objects that do nothing but carry data.
The third bullet is literal: in yesterday's testbench, copying a command is three
assignments, and comparing it is three `==`. With two more fields it is five and
five. Today that becomes `copy()` and `compare()`, written once.

---

<!-- .slide: data-machete="res/en/machete-debug.svg,res/en/uvm_class_diagram.svg" -->

## Agenda

#### *Day 5 · ≈ 4 h 30 · unit 6 · the data*

- Copying an object that contains another
- Transactions
- Constrained random

**By the end of the day you can:**

- **Write** a constraint that reaches a corner case, and **measure** whether the
  `dist` does what it says
- **Close** a bin that was left open, with a directed case asked for through
  `randomize() with {}`
- **Explain** the difference between copying the handle and copying the object,
  and what happens when the object contains another

Note:
The second one is the novelty of the day and the one that pays off the most at
work: measuring is half of it, closing is the other half. The three exercises of
the afternoon are that whole cycle —measure the `dist`, close the bin— and day 7
finishes it by accumulating seeds.
Row 12 of the self-assessment says **measure**, not **write**, and that is on
purpose: a `dist` with the weights right can give a histogram that lies, and
whoever never measured it has no way of knowing.
