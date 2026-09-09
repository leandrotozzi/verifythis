<!-- es-sha: 493758d4dcb6 -->
# Day 5 · second — measure your `dist`

No UVM, no DUT and no testbench: one class, one `dist` and a histogram. It is the
short exercise of the course.

`histograma.sv` has a class with a `rand byte unsigned A` and a constraint that
already says what we want: **10 % on `00`, 80 % in the middle, 10 % on `FF`**.
Run it first, before touching anything:

```sh
bash run.sh
```

## What is asked

That the three buckets give 10 / 80 / 10, with a tolerance of **±2 points** each.

The weights are already written and they are the right ones. **Do not change the
numbers.** What is wrong is something else, and the output of that first run tells
you which.

Done when `bash run.sh` prints `EXERCISE OK`.

## How to run it

```sh
bash run.sh              # with your file
SOLUCION=1 bash run.sh   # with the one in solucion/, to compare
SEED=7 bash run.sh       # another seed: the numbers move a little
```

It takes about 20 seconds, and almost all of it is the solver: Verilator resolves
every `randomize()` that has constraints by calling **z3** from outside, so 4000
randomizations are 4000 calls. If it tells you `Tried: $ z3 --in` and every bucket
gives zero, you are missing the install (`apt install z3` / `brew install z3`).

## The hint, if you need it

The difference between the solution and the initial file is **one character**.

## What it practises

`:=` against `:/`, and the rule that orders the section: **do not assume it,
measure it.** A badly written constraint does not fail, it lies — there is no
warning, there is no compilation error, and the testbench passes just the same.
The only thing that gives it away is the coverage that does not go up, and that is
noticed weeks later.

It is worth looking at the numbers with two or three seeds before calling it
closed: with 4000 samples the 10 % bucket moves half a point between runs. A
measured percentage is a sample, not the distribution.
