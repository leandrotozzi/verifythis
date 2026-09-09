<!-- es-sha: 246c56e3b625 -->
<!-- .slide: id="day6" -->

## Yesterday we left…

#### *Where the testbench stands*

- The data is an **object**: `command_transaction` with `do_copy`, `do_compare`
  and `convert2string`, and the scoreboard compares objects, not fields
- The stimulus is asked for instead of written: `randomize()`, `constraint`,
  `dist`, and the histogram that says whether the distribution does what it
  promises
- And **two** things are left stuck together that do not belong together: the
  `tester` is structure and stimulus at once, and the `env` names the monitor and
  the driver one by one

Note:
The day 6 recap has to name the two separations the unit makes, because there are
two and they get confused: the **agent** separates the structure and the
**sequence** separates the stimulus. Both are the same operation —taking
something out of the component tree— applied to different things.
The third bullet is the one to leave said in the student's own words: today, to
test three stimuli and their combinations, six test classes are needed. That
grows factorially, and it is the reason the unit exists.

---

<!-- .slide: data-machete="res/en/machete-debug.svg,res/diagrams/en/agents_agent.svg,res/diagrams/en/sequences_tb_completo.svg" -->

## Agenda

#### *Day 6 · ≈ 4 h 15 · unit 7 · the reusable testbench*

- Agents
- Callbacks
- Sequences

**By the end of the day you can:**

- **Say** what an agent with `is_active = UVM_PASSIVE` builds and what it does
  **not**
- **Explain** why a `uvm_sequence` does **not** show up in `print_topology()`
- **Remove** the last hard-wired line of a test, with `default_sequence` through
  `uvm_config_db`

Note:
The first two are rows 13 and 14 of the closing self-assessment. The 14th is the
question thrown on day 3, when the UVM class diagram showed up, and it gets
answered today: `uvm_object` is the **data** and `uvm_component` is the
**structure**.
The third one is what closes the unit and the day: when that line goes, no line
of the test names a component from inside the `env`, and only then is the
testbench truly reusable.
