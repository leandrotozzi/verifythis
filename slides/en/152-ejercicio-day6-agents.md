<!-- es-sha: 89b0bfae785b -->
## Exercise · Day 6 · 1 of 4

#### *The agent that only watches*

`cd code/ejercicios/d6-agents && bash run.sh`
<!-- .element: class="comando" -->

- The `env` has a single agent. Add the **passive** one on the second VTALU
- And make `is_active` actually count: today the agent builds driver and
  sequencer always
- It is graded with `+UVM_CONFIG_DB_TRACE`: the census of the tree is written by UVM, not by you

Note:
The exercise puts together the three things of the section that can be done wrong without the
compiler saying anything: `is_active`, the hierarchical scope of the `set()`, and the
`connect_phase` of the analysis ports.
The trap almost everybody is going to find is the scope: with `"*"` in both
`set()`, the second overwrites the first and both agents end up with the same
config — same BFM and same `is_active`. The
checker catches it by crossing the counts — the module sends 200 operations and the
sequence more than a thousand, so if both agents see similar numbers it means they
are watching the same interface.
And the shortcut of putting both in `UVM_PASSIVE` so it "passes" does not work either:
the checker demands that `clase_agent_h` still have a driver.
