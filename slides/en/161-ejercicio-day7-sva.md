<!-- es-sha: 5e7fbf141734 -->
## Exercise · Day 7

#### *The legacy module violates the protocol and nobody knew*

`cd code/ejercicios/d7-sva && bash run.sh`
<!-- .element: class="comando" -->

- The "boss's tester" of the agents drives its VTALU **by hand** for the
  multiplication, and it goes about getting the operand of the next one ready while it waits for
  `done`. It has been in production for years
- The scoreboard compares a thousand operations and does not find a single difference:
  the multiplier latched `A` and `B` on the first edge. **The bug is not a data bug**
- Write the property that does see it. The two `done` ones are already there, as a mould
- The checker asks for three things: that it fire on `modulo_bfm`, that it **not** fire
  even once on `clase_bfm`, and that the scoreboard stay green

Note:
The exercise gets solved with a three-line property, but the second
condition of the checker is the one that teaches: whoever samples it on `posedge` is going to see
false positives on the interface that **does** respect the protocol, and the message
is going to send them to look at the edge. It is the two-clocks slide, cashed in.
It is worth insisting on the `cover property` hint for whoever gets no firings:
the natural reflex is to loosen the property until it does something, and it is the wrong
reflex. The cover at 0 tells *"the property is badly written"* apart from *"the
antecedent does not occur"*, and they are two different problems.
And the moral that goes beyond the exercise: nobody wrote the property
thinking about the boss's module. It lives in the interface, and that is why it checks
everybody who uses it — including code that was written five years before
this testbench existed.
