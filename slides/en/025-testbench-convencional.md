<!-- es-sha: 82fae0933b90 -->
## The conventional testbench

#### *The VTALU plan, with three columns to fill*

| Feature | Scenario | Stimulus | Check | Measure |
| --- | --- | --- | --- | --- |
| ALU | the six operations | | | |
| ALU | operands at `00` and at `FF` | | | |
| reset | operate after a reset | | | |
| mult | a mult after a single-cycle one | | | |
| ALU | the same operation twice in a row | | | |
| sub | subtract too much: `A < B`, and `ovf` goes up | | | |

- Six rows that come out of the spec, and none of the right-hand columns yet.
  This section fills **two**: the stimulus provokes them and the scoreboard says
  whether the result was right
- The third one —**which bin gets filled when it happens**— is the next section
- The testbench has three parts because the plan has three columns to fill

Note:
The order matters and it is the one from the previous unit: the plan first,
the testbench after. If you write the testbench first, you end up measuring
what the testbench does instead of what the spec asks for.
Worth reading the six rows one at a time and asking which one is missing. The
answer that usually comes up —"test intermediate values"— is good for
discussing why it is not there: 256 × 256 × 5 combinations do not get
simulated, and that is where random comes in.
The last one is the one that brings today's topic: the DUT has TWO outputs, and
a row of the plan that only closes by looking at both. A scoreboard that
compares `result` and nothing else passes green with `ovf` stuck at zero.
The table comes back twice: in functional coverage with the measure column
filled in, row by row, and at the end of that whole section, with the twelve
rows and the three columns. Worth announcing now so nobody reads it as
decoration: it is the same table, filling up.

---

## The conventional testbench

#### *The stimulus: a thousand operations, and the protocol by hand*

{{code:code/u2/convencional/vtalu_tb.sv#stimulus-loop}}

- A thousand rounds: pick the operation, pick the operands, raise `start`, wait for
  **an edge with `done` up**, lower `start`
- The `case` is there because of the fine print of the spec: `no_op` does not raise
  `done`, `rst_op` pulses `reset_n`, and the rest wait
- `get_op()` and `get_data()` bias the random towards the edges —00 and FF— to
  reach the cases the plan asks for. It is *constrained random* written by hand
- `enviadas` gets counted here and `chequeadas` in the scoreboard, and a `final`
  demands they match: it is the testbench checking itself
- Notice who knows about the protocol here: **the tester**. In interfaces and BFM that moves
  to the BFM and in the body of the `repeat` shrinks to one line

Note:
This is the "before" slide of the whole course: the stimulus and the protocol mixed
in the same loop. Worth pointing at it, because the next five units
are successive separations of these thirty lines.
The `do … while (done == 0)` of the `default` is the one that hangs if the DUT does
not answer, and it is the place the student is going to end up in the first time they
break something. The safety net is `VLT_TRACE=1` and the waves.
And why it is not a `wait(done)`, which is the first thing anybody writes: on the
one-cycle operations `done` is a level, and on the `negedge` where the tester loads
the next operation **it is still up from the previous one**. The `wait(done)` does
not block, `start` drops at the same instant and the DUT never sees that operation.
There is no error: the scoreboard does not fire, and the coverage —which samples
`op_set`— counts it anyway. This testbench had it, and it dropped four in ten
one-cycle operations with the report in green: on `d1`, 77 shifts checked
against 130 with the fix. What catches it is the sent-versus-
checked counter, and it is the cheapest silent trap to guard against.
The bias of `get_data()` —a quarter at 00, a quarter at FF, half in the
middle— is exactly what the transactions are going to write in one line with `dist`
and `:/`. Worth naming it now so that the saving is visible later.

---

## The conventional testbench

#### *The self-checking: predict and compare*

{{code:code/u2/convencional/vtalu_tb.sv#scoreboard-block}}

- An `always @(posedge done)`: every time the DUT says it finished, the
  scoreboard predicts the result and compares it
- The `#1` is not decoration: without it the signals get read at the same instant
  `done` goes up and a delta race can be swallowed
- `no_op` and `rst_op` do not raise `done`, so this block should not run with
  them. The `if` is defensive —with no prediction for those two it would compare
  garbage— and inside goes `chequeadas++`, the other half of the counter
- The covergroup —the third leg— is the section that follows

Note:
The reference model is four lines of `case` because the DUT is an ALU. On
a real project it can be a model in C or the RTL of the previous
generation, but the shape is always this one: **predict with something that is not the DUT, and
compare**.
That the scoreboard reads `A`, `B` and `op_set` off the wire at the moment of the result
works only because the protocol forces them to stay stable. It is fragile, and in
the analysis ports it will be replaced by a queue of commands the monitor sends.
And the `$error` here is going to be a `` `uvm_error `` from reporting on: same
concept, with a counter and a severity policy behind it.

---

## The conventional testbench

#### *How do you know the scoreboard checks anything?*

{{code:code/u2/convencional/mutante.txt}}

- A thousand operations and not one error. Now **the same testbench with the
  DUT broken on purpose**: `VTALU_BUG=1 bash run.sh` flips bit 0 of the result
- It fails on the first comparison. That —and not the earlier `PASS`— is what
  proves the scoreboard looks at the result
- A scoreboard that **never saw an error** is not proven: it may have compared
  against itself, or compared nothing at all
- `make mutante` does this with the three testbenches of days 1 and 2, and
  fails if any of them does **not** fail. It is the first answer to the
  question of the day

Note:
Run it live, it takes seconds because there is no UVM: first `bash run.sh` —a
thousand operations, silence, and the coverage summary—, then
`VTALU_BUG=1 bash run.sh`, which ends in the line on the slide and a `$stop`.
What has to be said in so many words is what that line proves and what it does
not. It proves the scoreboard compares the bit the bug touched. It does not
prove it compares `ovf`: a bug that only touched `ovf` is another run, and that
is why the plan has a row for each output.
This is the short answer to the first slide of the day: the regression that
said `PASS` and sent the bug to the fab had never seen a `FAILED`. It did not
know whether it was checking. A `PASS` says nothing until you know what
`FAILED` would have said.
And it is not a day-1 trick: it is the practice that runs through the course.
`+BUG=1` in the day 7 capstone and `+GOLDEN_BUG` in the day 8 reference model
are this very thing, and the exercise checkers demand it.

---

## The conventional testbench

#### *Unit summary*

- The testbench has **three parts** because the plan has three columns to
  fill: stimulus, self-checking and measure. Today they are loose in one file
- The stimulus **biases the random towards the edges** —`00` and `FF`— because
  uniform randomness almost never visits them
- The `#1` before reading the signals is not decoration: without it you read in
  the very instant the DUT writes, and the result is undefined
- A `PASS` proves nothing until you have seen the `FAILED`: **`VTALU_BUG=1`** is
  the way to see it, and `make mutante` the way not to forget
- And what to look at for interfaces and BFM: **the tester knows the
  protocol**. It moves `start` and waits for `done` by hand

Note:
The last bullet is the one that orders the rest of the day: this testbench
works, it is proven, and it is badly divided. The tester knows how `start` is
wiggled and the scoreboard knows when to read `done`: the protocol lives in two
places of the same file, and the day it changes both have to be touched.
That is the whole motivation for interfaces and BFM, and it is worth leaving as
an open question instead of answering it here. Before that, the next section
fills in the third column.
