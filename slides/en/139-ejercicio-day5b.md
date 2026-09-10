<!-- es-sha: be632c7afec5 -->
## Exercise · Day 5 · 2 of 3

#### *Measure your `dist`*

`cd code/ejercicios/d5b && bash run.sh`
<!-- .element: class="comando" -->

- One class, one `dist` and a histogram. No UVM, no DUT, no testbench
- The weights **already say 10, 80 and 10**. Run it first, and look at what comes out
- What is asked is that the three buckets give 10 / 80 / 10, with ±2 points of tolerance
- The difference between what is there and the solution is **one character**

Note:
It is the short exercise of the course and the one to leave for whoever ran out of
time: it compiles and runs on its own, without UVM.
The point is in the order: it gets run **before** touching anything. The file says
10, 80 and 10, the output says 0.1 % on the edges, and there the question of the
section appears on its own — if the numbers are right, what is wrong? The operator
is wrong, and there is no warning to say so.
It is worth asking them to run it two or three times with different `SEED=` before
calling it closed: with 4000 samples the 10 % bucket moves a good point between
runs, between 9 and 11 — that is why the checker accepts ±2. A measured percentage is a sample, not the distribution — which is the other
half of the rule of the section.
An infrastructure detail worth mentioning if somebody asks why a program with no
DUT takes twenty seconds: Verilator resolves every `randomize()` that has
constraints by calling **z3** from outside, so that is 4000 calls to an external
process. And if they do not have it installed, `randomize()` returns 0 and every
bucket gives zero — another one that does not break, it lies.
