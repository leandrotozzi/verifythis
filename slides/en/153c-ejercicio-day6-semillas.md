<!-- es-sha: a4527060f67f -->
## Exercise · Day 6 · 4 of 5

#### *The same sequence, another seed*

`cd code/ejercicios/d6-semillas && bash run.sh`
<!-- .element: class="comando" -->

- The only exercise of the course without SystemVerilog: what gets written is the
  **regression**, six lines of shell
- Run the same test with seeds 1 to 5 and **merge** the five coverages
  with `verilator_coverage --write`
- It is graded by checking that the merge covers more than the best of the five on its own

Note:
It is the last row of the *coverage closure* table, done. And it closes the arc with
the previous exercise: one is the directed case, the other is the regression, and they are
the two tools that do not replace each other.
The detail to underline is why the test sends **25** operations and not
a thousand: with a thousand this does not work. It is measured and it is on the slide *"another seed, and
again"* — `u2/convencional` and `u7/sequences` give 66 out of 76 with any seed, and the merge
too. With 25 the stimulus has not saturated yet and there each seed does cover a
different piece: 41 to 47 bins each, 62 for the five merged.
The rule they take away, in one line: another seed **accumulates** while the
stimulus has not saturated, and **reproduces** an intermittent failure. It does not fill a bin the
stimulus cannot reach.
And the merge command is worth naming for what it is in the industry:
`verilator_coverage --write` is here what the `ucdb` merge is in Questa. A real
regression is a hundred seeds overnight and one single number in the morning.
