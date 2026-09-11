<!-- es-sha: d70d6dfe50a4 -->
## Exercise · Day 3 · 2 of 2

#### *The `uvm_error` that says nothing*

`cd code/ejercicios/d3b && bash run.sh`
<!-- .element: class="comando" -->

- The scoreboard is **right** —it catches every mismatch— and when it fails it
  says `FAILED` and nothing else: even less than the line of the day-1 waves
  exercise
- Make the `uvm_error` say **which one** failed: `A`, `B`, the operation, the
  DUT's result and the one you predicted
- And make the one that **passes** get printed too, at `UVM_HIGH`, so that it
  does not show up in the everyday log
- The checker watches the same bus you do and knows which was the first that
  failed

Note:
It is the short exercise of day 3 and it closes the arc the day-1 waves
exercise opened: there the student was the one reading the `FAILED`, here they
are the one writing it. Ten minutes of typing, and the point is not the `$sformatf`.
The point is the second request, which is the one that surprises: the `PASS`
**also** gets written. The typical reaction is *"what do I want a thousand PASS
lines for?"*, and the answer is that you do not want them today: you want them
the day operation 700 fails and you need to know what happened in 699. That is
why it gets written **and** hidden behind `UVM_HIGH`. That is the difference
between severity and verbosity, told with your hands.
The checker runs the same testbench three times, and it is worth telling because
it is how a log gets tested: one with the DUT broken —`+VTALU_BUG`— so the error
fires and can be read, one with the usual verbosity to demand that the `PASS` is
**not** there, and one with `+UVM_VERBOSITY=UVM_HIGH` to demand that it is there
once per comparison. A message that was not tested all three ways is a message
that is going to lie in the nightly regression.
