<!-- es-sha: 5f9fe43550a7 -->
<!-- .slide: id="day3" -->

## Yesterday we left…

#### *Where the testbench stands*

- The day 1 testbench **without a single module**: three classes, one that binds
  them, and a `top` that only instantiates the DUT and the BFM
- The BFM gets into the classes through a **virtual interface**, which is the
  only way a class has of touching signals
- And the factory is already written **by hand**: a `case` that has to be edited
  every time a new type shows up. Today the one you do not edit shows up

Note:
Day 3 is where UVM walks in, so the recap has an extra job: making it clear that
what is coming **replaces** pieces the student already wrote, and is not a pile
of new pieces to learn from scratch. The whole unit can be read as "this thing
you did by hand, the library brings it done".
The third bullet is the hook: the `case` of `060` is exactly what
`` `uvm_component_utils `` does on its own, and saying it here stops the macro
from being a magic formula.

---

<!-- .slide: data-machete="res/en/TB_UVM.svg,res/diagrams/en/env_uvm_incantation.svg,res/diagrams/en/UVM-hierarchy.svg,res/en/machete-debug.svg" -->

<!-- .slide: data-transition="convex" -->

## Agenda

#### *Day 3 · ≈ 4 h 30 · unit 4 · UVM walks in*

- Tests
- Components and phases
- The env: structure and stimulus
- Reporting: verbosity and *actions*

**By the end of the day you can:**

- **Explain** why a UVM simulation ends at `t=0` if nobody raises an objection
- **Say** why `build_phase` runs top-down and `connect_phase` the other way round
- **Make** a scoreboard that fails say **something more** than "it failed"

Note:
The third one is the one that pays off the most in the long run and the one most
underestimated: it is row 10 of the closing self-assessment and the one aiming at
the 47 % of day 1. A `uvm_error` that prints *"FAIL"* leaves whoever is debugging
where they were; one that prints the transaction, the prediction and the time
saves them half a morning.
The first two are library mechanics and they are the ones most often answered
with an *"it rings a bell"*. The second exercise of the day exists so that they
stop ringing and start having been suffered.
