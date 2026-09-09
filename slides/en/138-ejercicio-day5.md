<!-- es-sha: 17ddbff43551 -->
## Exercise · Day 5 · 1 of 2

#### *The scoreboard screams and the DUT is healthy*

`cd code/ejercicios/d5 && bash run.sh`
<!-- .element: class="comando" -->

- The TB of the transactions reports `FAIL` on almost every operation
- The DUT is the same one that has been passing since the spec. The bug belongs to the TB
- The messages that give it away are `UVM_HIGH`: turn the verbosity up
- If you get stuck, the **debug toolbox** appendix has the row for this symptom;
  the **silent traps** one has the cause

Note:
It is the exercise that looks most like a day at work: the scoreboard screams and
you have to decide who to believe.
Let them start without the hint. Almost all of them are going to look at the RTL
first — that is already half the lesson. When they get stuck, the hint is the
verbosity: the `uvm_info` of the monitor are UVM_HIGH and they show what the
monitor says it saw, which does not match what the scoreboard compares.
The bug is a single line of `command_monitor.svh`: the monitor copies one of
the two operands wrong.
