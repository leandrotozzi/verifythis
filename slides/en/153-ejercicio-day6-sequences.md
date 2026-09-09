<!-- es-sha: 9e452bd53946 -->
## Exercise · Day 6 · 2 of 3

#### *A sequence that only multiplies*

`cd code/ejercicios/d6-sequences && bash run.sh`
<!-- .element: class="comando" -->

- Write `mult_sequence` and the `mult_test` that starts it
- The driver, the agent and the `env` are already there: adding stimulus **does not touch the
  structure**, which is precisely what the section came to demonstrate
- It is graded crosswise against what the `chequeo` sees on the bus, not against your count

Note:
It is the same exercise as day 2 and day 3, for the third time and with the final
tool: "I want it to only multiply". On day 2 it was solved by adding `virtual`,
on day 3 with a factory override, and today by writing twenty lines of
`body()` without touching a single class of the testbench. It is worth having them compare the
three: that is the whole story of the course in one exercise.
The trap they are going to find is the first one of the section: if the sequence does not
send a `rst_op` as the first item, the VTALU starts up with `reset_n` at 0, `done`
never rises and the driver stays in the first `finish_item()`. The `run.sh` has
a `+UVM_TIMEOUT` set so that finishes with a message instead of hanging.
