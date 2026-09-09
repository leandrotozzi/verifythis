<!-- es-sha: dba825f69b1f -->
## Exercise · Day 6 · 3 of 4

#### *Closing a bin*

`cd code/ejercicios/d6-bins && bash run.sh`
<!-- .element: class="comando" -->

- The test sends a reset and **60 random operations**, and the report shows the bin
  *"both legs at `FF`, multiplying"* empty
- Write the one-item sequence that closes it. But **ask for it with
  `randomize() with {}`**, not by assigning the fields
- It is graded by comparing the coverage before and after: it has to go up
- It is **row 3** of the verification plan of day 1: the only one of the twelve whose
  stimulus column says *directed case*

Note:
It is the exercise the course was missing, because *coverage closure* shows up twice
as a noun and never as a verb. Here the student does the whole cycle:
run, look at which bin was left empty, write three lines, run again.
The trap is set on purpose and it is the one from constrained random: `command_transaction`
has a `dist` on `A` and on `B`, and Verilator resolves the `dist` by choosing
a value **before** looking at the `with`. With the distribution active, `with {A == 8'hFF}`
resolves one out of every four times and the rest returns 0. Whoever does not read the hint
is going to see an exercise that sometimes passes and sometimes does not — which is exactly the
symptom the section describes.
The way around it is `constraint_mode(0)`, and it is worth defending it as a design decision and
not as a patch for the simulator: a **directed** case does not want a distribution of
probabilities, it wants a value.
The seed of the `run.sh` is fixed. Without fixing it, some runs would fill the
bin on their own with the 60 random ones — and that is the next exercise.
