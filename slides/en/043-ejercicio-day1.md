<!-- es-sha: 5efbb277640f -->
## Exercise · Day 1 · 1 of 2

#### *A new operation, end to end*

`cd code/ejercicios/d1 && bash run.sh`
<!-- .element: class="comando" -->

- The VTALU has a **free opcode**, `3'b110`. Teach it to shift, and
  teach the TB that it has to verify it too
- It gets touched in **three** places: the RTL, the stimulus with its check, and **the
  measure** — the bin that does not exist today
- The `run.sh` fails until it prints `EXERCISE OK` **and the report closes with
  77 covered bins**; the solution is right next to it

Note:
Half an hour, and it is worth leaving them alone: the statement and the README are enough.
The guaranteed stumble is the width: the hardware shifts by `B[2:0]`, not by
the whole `B`, so with `B = 8'h20` it shifts zero places and not thirty-two. The
scoreboard model has to do the same or the TB they wrote themselves
is going to accuse them. It is warned about in the README, and it still happens.
The third step is the most skipped one and the only one that fails **silently**:
`bins single_cycle[]` covers the range `[add_op : xor_op]`, which reaches up to
`3'b100`. `shr_op` falls outside every bin, the simulation passes green and
— here is the worst part — the report still says **100 %**: 76 out of 76. The
missing bin does not lower the percentage because it never made it into the
denominator. There is the lesson that holds for the rest of the course: an opcode
nobody measures is an opcode nobody verified, and the percentage is precisely the
metric that cannot see it.
With the solution it is 77 out of 77, starting from 86.8 % (66 out of 76). The ten
that were missing were a single one: the bucket Verilator invents for `3'b110`, the
value the enum did not have — and the shift is precisely `3'b110`, so it fills it
along the way. Worth showing both numbers and not only the percentage: that is why
the `run.sh` demands, on top of the 100 %, that `single_cycle` has one more bin: a
half-done job reaches the 100 % too.
