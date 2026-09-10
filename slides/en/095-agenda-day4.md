<!-- es-sha: 4cf43320e171 -->
<!-- .slide: id="day4" -->

## Yesterday we left…

#### *Where the testbench stands*

- UVM walked in: `run_test()`, the test, the phases, the `env` and the
  scoreboard, and the `+UVM_TESTNAME` that picks the class from the command line
- The **objection** is what keeps the simulation alive, and the reporting already
  tells verbosity from *action*
- And one bottleneck was left: the scoreboard is **one** and it is wired to the
  monitor. The day there are two listeners, the one that publishes has to be
  edited

Note:
The day 4 recap has to leave the observer problem served, because the whole unit
is that: a producer that does not know its listeners.
It is worth asking the question and waiting: *"if tomorrow they want to measure
coverage as well as compare, where do they touch?"*. The natural answer —"I add a
call in the monitor"— is exactly the one the unit comes to take apart.

---

<!-- .slide: data-machete="res/diagrams/en/analysis-ports_fig102.svg|VTALU testbench with analysis ports,res/diagrams/en/threads_fig124.svg|Interthread communication with put port, get port and uvm_tlm_fifo" -->

## Agenda

#### *Day 4 · ≈ 4 h · unit 5 · how the components talk*

- One producer, many listeners
- A single place that watches the wire
- When somebody has to wait
- Who waits for whom

**By the end of the day you can:**

- **Hang** a new subscriber off an analysis port **without touching the one that
  publishes**
- **Choose** between an analysis port and a TLM FIFO, and say which of the two
  blocks
- **Remove** the `#500` at the end of a test and replace it with the objection
  that belongs there

Note:
The first one is row 11 of the closing self-assessment and it is what defines the
unit: the observer exists so that adding a listener does not touch the one that
publishes.
The third one is the second exercise of the day and it stands as an objective on
its own: the `#500` is the patch everybody writes the first time, and taking it
out forces you to understand what keeps the simulation alive.
