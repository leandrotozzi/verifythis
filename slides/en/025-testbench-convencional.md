<!-- es-sha: c1b76b51fba2 -->
## The conventional testbench

#### *Coverage First Methodology*

- We define what we want to cover and then we build the TB
- The goal is to test the whole functionality of the ALU and  
  simulate *ALL* the lines of the RTL code
- The TB has 3 parts: stimulus, self-checking and coverage

Note:
The order matters: the coverage plan first, the testbench after. If you
write the TB first, you end up measuring what the TB does instead of what the
spec asks for. The six bullets on the next slide are the verification plan
of the whole VTALU: read them one at a time and ask which one is missing.

---

## The conventional testbench

#### *The VTALU verification plan*

- Test every operation
- Corner cases: inputs all at 0/1 for every operation
- Run every op after a reset
- Run a multiplication after a single-cycle op and the other way round
- Simulate every operation run twice in a row
- **Subtract too much** —`A < B`— and see that `ovf` goes up

- Six sentences in plain English. The whole section is translating them into code: the
  **stimulus** produces them, the **covergroup** counts them, the **scoreboard** says
  whether the result was right

Note:
Worth reading the six points one at a time and asking which one is missing. The answer that
usually comes up —"test intermediate values"— is a good one to discuss why it is not
there: 256×256×5 combinations do not get simulated, and that is where the random comes in.
The plan written before the testbench is the whole discipline of the unit. If
you write it after, you end up describing what the testbench already does.
The six points come back in the next section turned into bins, one by
one. Worth announcing now so that nobody reads them as decoration.
The last one is the one that brings the topic of the day: the DUT has TWO outputs, and one row
of the plan that only closes by looking at both. A scoreboard that compares `result`
and nothing else passes green with `ovf` stuck at zero.

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
  to the BFM and this task shrinks to one line

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

#### *Summary of the unit*

- The order is **coverage first**: you write what has to be covered, and only
  then the testbench that covers it
- The VTALU verification plan is **six sentences in plain English**. The whole
  day 1 is translating them into code
- A testbench has **three parts**, and in this section all three are loose:
  stimulus, self-checking and coverage
- The stimulus **biases the random towards the edges** —`00` and `FF`— because uniform
  chance almost never visits them
- The `#1` before reading the signals is not decoration: without it you read at the same
  instant the DUT writes, and the result is undefined
- And what to look at for the section that follows: **the tester knows about the
  protocol**. It moves `start` and waits for `done` by hand

Note:
The last bullet is the one that orders the day: this testbench works and is badly
split up. The tester knows how `start` gets wiggled and the scoreboard knows when
to read `done`: the protocol lives in two places of the same file, and the day it
changes both have to be touched.
That is the whole motivation for interfaces and BFM, and it is worth leaving it as an
open question instead of answering it here.
