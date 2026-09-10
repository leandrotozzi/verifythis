<!-- es-sha: 7d2db865bb54 -->
<!-- .slide: id="day8" -->

## Yesterday we left…

#### *Where the testbench stands*

- The capstone handed in: an APB slave, its spec, and a whole testbench written
  from a blank sheet — monitor, driver, scoreboard, coverage and properties
- The scoreboard of that testbench **predicts by hand** the value of every
  register, and the coverage of the bus was written row by row
- And that is done the same way at work… until the DUT has sixty registers. That
  is when both things get modelled, and that is the whole of day 8

Note:
This day is **optional and it goes after the wrap-up**, and both things are on
purpose. The course ends on day 7: whoever got that far wrote a complete UVM
testbench from a blank sheet and lacks nothing to go to work. What is here is
what gets added once that has happened.
The recap has a concrete job on day 8: the three pieces of today are only
understood as a replacement for something the student has **just written by
hand**. RAL replaces the register-by-register prediction, the golden model in C
replaces the whole prediction, and the second capstone shows where the pattern of
the first stops working. Without the capstone done, all three are abstractions
without a problem.

---

<!-- .slide: data-machete="res/en/uvm_class_diagram.svg|The UVM base class hierarchy,res/diagrams/en/ral_camino.svg|The RAL data path: from the model write down to the bus · and from the monitor up to the mirror through the predictor,res/diagrams/en/sequences_tb_completo.svg|The whole testbench: the sequence cloud · the agent with sequencer and driver · and the analysis layer in the env" -->

## Agenda

#### *Day 8 · ≈ 4 h · optional · what comes after the capstone*

- RAL, unit 9 — the register model over the same APB
- The reference model in C, through DPI
- The second capstone: a FIFO with backpressure

**By the end of the day you can:**

- **Read and write** a register by name, without writing a single `PADDR`, and
  say what the adapter and the predictor do
- **Plug in** a reference model written in C, and prove it with a mutation
- **Write** a scoreboard for a DUT where a table is not enough

Note:
For whoever teaches it: in a company this is another half day, and it usually
gets taught when the group has real registers in the project. In a term it is the
optional unit, or the final assignment for those who want a high mark.
The three objectives are deliberately concrete and not "understand RAL": day 8
has no row in the `175b` self-assessment, so the rubric the student takes away is
these three verbs and the eight-question review. The third is the one that pays off the most of the three and
the least expected — a FIFO has order and occupancy, and that does not fit in a
four-row table.
