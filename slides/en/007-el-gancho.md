<!-- es-sha: 494d5a6b24a5 -->
## The log says it failed

#### *And the DUT is healthy*

```text
$ cd code/ejercicios/d1b && bash run.sh
FAILED: A: e5  B: 0  op: mul_op result: fe01 ovf: 0
```

- `e5 × 00` is `0`, not `fe01`. The scoreboard is right: **something failed**
- The DUT is right too: **it is not broken**. That `fe01` is the result of
  another operation, which arrived late
- And the log has not one line more. Which operation, in which cycle, who
  overwrote whom: none of that is here
- That gap between *"it failed"* and *"why"* is **almost half** of a verification
  engineer's time, and it is what the week is about

Note:
This is the first slide with something running, and it goes here on purpose:
before any chart, before the word UVM, the student has to have seen the problem.
It is the `d1b` exercise, the second one of today, and in class it is worth
running it live — it is four seconds, it does not compile UVM.
The question to throw out and **not** answer: *"with that line, where would you
start?"*. The answers that will come are `$display` and running again, which is
exactly what the course comes to replace. The answer is in an `ondas.vcd` the run
left alongside and nobody has opened yet.
And the honest close, which is the promise of the whole course: this is not about
writing testbenches faster, it is about the log saying why when it fails — and it
will fail. The figure in the bullet below, the 47 %, comes from the survey on the
next slide.
