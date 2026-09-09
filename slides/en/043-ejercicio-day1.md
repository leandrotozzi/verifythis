<!-- es-sha: 8bd1c74ac5d4 -->
## Exercise · Day 1 · 1 of 2

#### *A new operation, end to end*

`cd code/ejercicios/d1 && bash run.sh`
<!-- .element: class="comando" -->

- The VTALU has a **free opcode**, `3'b110`. Teach it to shift, and
  teach the TB that it has to verify it too
- It gets touched in **three** places: the RTL, the stimulus with its check, and **the
  measure** — the bin that does not exist today
- The `run.sh` fails until it prints `EXERCISE OK`; the solution is right next to it

Note:
Half an hour, and it is worth leaving them alone: the statement and the README are enough.
The guaranteed stumble is the width: the hardware shifts by `B[2:0]`, not by
the whole `B`, so with `B = 8'h20` it shifts zero places and not thirty-two. The
scoreboard model has to do the same or the TB they wrote themselves
is going to accuse them. It is warned about in the README, and it still happens.
The third step is the most skipped one and the only one that fails **silently**:
`bins single_cycle[]` covers the range `[add_op : xor_op]`, which reaches up to
`3'b100`. `shr_op` falls outside every bin, the simulation passes green and
the coverage does not move. There is the lesson that holds for the rest of the course:
an opcode nobody measures is an opcode nobody verified.
With the solution the coverage goes from 86.8 % to 100 %. Worth showing the number
before and after: it is the whole argument of the morning in two lines of the report.
