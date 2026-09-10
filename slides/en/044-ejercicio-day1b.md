<!-- es-sha: 22a0374e05f0 -->
## Exercise · Day 1 · 2 of 2

#### *The waves: when the log is not enough*

`cd code/ejercicios/d1b && bash run.sh`
<!-- .element: class="comando" -->

- The run aborts with **a single line**: `FAILED: A: e5  B: 0  op: mul_op
  result: fe01 ovf: 0`. `e5 * 00` is `0`, not `fe01` — and the DUT is healthy
- That is where what the log gives you ends. The `run.sh` leaves **`ondas.vcd`** next to it:
  `gtkwave ondas.vcd`
- **Stage 1:** two times that only exist in the viewer, in `respuesta.txt`.
  **Stage 2:** the line of the BFM that explains them
- It is the only exercise of the course that is **not solved by reading the log**

Note:
Half an hour, and it is the exercise that justifies the debug appendix: there it says that
the waves are the tool 47 % of the work gets done with, and up to here
the course had not made them use one even once.
The bug is a protocol one and it is the same one that comes back in the capstone: `send_op`
**counts edges** instead of waiting for the handshake. For single-cycle operations it
makes no difference; the multiplication takes four, so `send_op` returns too
early, the next stimulus overwrites `A` and `B`, and when `done` finally goes up the
scoreboard compares the new operands against the old result.
That is why the two times stage 1 asks for are not bureaucracy: the second is the
`done` of the first multiplication, and whoever looks for it in the viewer **sees** that
`A` and `B` have already changed. That is the answer to the *why*, and there is no way to
read it in the log.
The question to throw at the group when they finish: if the multiplier went
from four edges to five, which of the two versions of `send_op` finds out?
Neither counts right; only the one that waits for `done` keeps working. It is literally the
clue of the APB wait state of day 7.
