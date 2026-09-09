<!-- es-sha: e3bd92f37022 -->
# The verification plan

The most professional deliverable of the discipline, and the cheapest to write:
a table. It gets written **before** the testbench —if it is written afterwards it
describes what the testbench already does instead of what the spec asks for— and
it gets filled in as the testbench grows.

This file is three things: what the five columns are, the **VTALU** plan filled
in with the file where each row lives, and an **empty template** to copy and fill
in for the day 7 capstone.

## The five columns

| Column | The question it answers | What does **not** go in it |
|---|---|---|
| **Feature** | which part of the spec does this row come from? | the name of a testbench file |
| **Scenario** | which concrete situation has to be provoked? | *"test the ALU"* — that is not a scenario |
| **Stimulus** | who provokes it: random or a directed case? | *"by hand"* |
| **Check** | who says it was right? | *"you look at the waveform"* |
| **Measure** | which bin or which `cover` fills when it happens? | *"you see it in the log"* |

Three rules come out of those columns:

1. **One row per scenario, not per feature.** A feature with three corner cases
   is three rows, and they get closed one at a time.
2. **If the check column says *"by eye"*, the scenario is not verified.** It is
   *simulated*, which is another thing. The difference is who finds out when it
   fails at three in the morning in the regression.
3. **If the measure column is empty, nobody is going to know the scenario never
   happened.** A case random never got to touch and that has no bin is
   indistinguishable from one that happened a thousand times.

And a distinction the course makes on day 7 that orders the check column: **the
scoreboard checks *what* the DUT computes; the assertions check *how* you talk to
it.** A serious plan has both.

## The VTALU plan, filled in

The twelve rows of the course, with the file where each one lives. The check
column says *scoreboard* or *assertion* depending on which half the row belongs
to.

| # | Feature | Scenario | Stimulus | Check | Measure | Where it lives |
|:--:|---|---|---|---|---|---|
| 1 | ALU | the six operations | random | scoreboard | `coverpoint op_set`, one bin per op | `u7/sequences/tb_classes/coverage.svh` |
| 2 | ALU | operands at `00` and at `FF` | `dist` skewed to the edges | scoreboard | cross `op_00_FF` | `u7/sequences/tb_classes/command_transaction.svh` · `coverage.svh` |
| 3 | mult | maximum product: `FF` × `FF` | **directed case** | scoreboard, 16 bits | bin `mul_max` of the cross | `u7/sequences/tb_classes/maxmult_sequence.svh` |
| 4 | reset | operating after a reset | `rst_op` interleaved | scoreboard | transition bin `rst_op => op` | `u7/sequences/tb_classes/reset_sequence.svh` |
| 5 | mult | a mult after a single-cycle one | random | scoreboard | transition bin `sngl_mul` | `u7/sequences/tb_classes/coverage.svh` |
| 6 | ALU | the same operation twice in a row | random | scoreboard | repetition bin `twoops` `[* 2]` | `u7/sequences/tb_classes/coverage.svh` |
| 7 | sub | subtracting too much: `A < B`, and `ovf` goes up | random | scoreboard, **two outputs** | bin `hubo_borrow` | `u7/sequences/tb_classes/coverage.svh` |
| 8 | sub | `A == B`: the result is 0 and `ovf` does **not** go up | random | scoreboard, two outputs | bin `sub_00`/`sub_FF` of the cross | `u7/sequences/tb_classes/coverage.svh` |
| 9 | ovf | `ovf` does not go up for any other operation | random | assertion `a_ovf_solo_en_sub` | `c_ovf`, `c_sub_sin_borrow` | `u8/assertions/vtalu_bfm.sv` |
| 10 | protocol | the operands are not touched with `start` high | random | assertion `a_operandos_estables` | `cover property` | `u8/assertions/vtalu_bfm.sv` |
| 11 | protocol | `done` arrives, and before 5 cycles | random | assertion `a_done_llega` | `c_mult_4ciclos`, `c_un_ciclo` | `u8/assertions/vtalu_bfm.sv` |
| 12 | protocol | `no_op` is the only one that does not answer | random | assertion `a_no_op_sin_done` | `cover property` | `u8/assertions/vtalu_bfm.sv` |

Six things this table says that no single slide says:

- **Row 3 is the only one with directed stimulus**, and that is not a whim:
  `FF` × `FF` is one combination out of 65,536 and random does not visit it in a
  thousand operations. The plan is what makes it obvious **which test has to be
  written**, and it is exactly the exercise
  [`d5c`](../../code/ejercicios/d5c/), which closes this row.
  And watch the name: it is the **maximum product**, not an overflow. `FF` × `FF`
  gives `FE01`, which fits exactly in the 16 bits of `result` —8 bits by 8 never
  go past 16— and the DUT forces `ovf` to 0 on every multiplication. That is why
  the bin is called `mul_max`. The one that overflows is the subtraction, and
  those are rows 7 and 8.
- **Rows 4, 5 and 6 are not measured with Verilator.** They are transition bins,
  and 5.052 still does not compile them: in the code they sit between
  `` `ifndef VERILATOR ``. The row stays anyway —the scenario exists— with the
  limitation noted. See [`verilator.md`](verilator.md).
- **Rows 7 and 8 are the reason the scoreboard looks at TWO outputs.** `result`
  alone is not enough: a subtraction that comes out right with `ovf` stuck at 0
  passes the check and is wrong. It is the row that forces `result_transaction`
  to have two fields and not one.
- **Row 9 is an assertion and not a scoreboard, and the difference matters.** The
  scoreboard checks the `ovf` of the operations that *happened*; the assertion
  checks that it does not show up where it does not belong. Two different
  questions about the same signal.
- **Rows 10, 11 and 12 have no scoreboard and that is not an oversight.** They
  are protocol rules: the scoreboard does not see them because the result comes
  out right anyway. It is the blind bug of the assertions and of the exercise
  [`d7-sva`](../../code/ejercicios/d7-sva/).
- **Row 11 has a cover that never fills, on purpose**: `c_mult_3ciclos` stays at
  0 because the multiplication takes four edges —which is what the spec table
  says, and the pipeline gets counted by eye as three—. A cover at zero is
  information, not a failure.

## The template, for the capstone

The day 7 capstone —[`code/ejercicios/d7-final`](../../code/ejercicios/d7-final/)—
is handed in with its plan filled in, which is exactly what gets handed in on a
project. The one for `apb_regs` is already written, at the end of its `spec.md`,
and it has the same five columns: **copy that table and add the rows you are
missing** as you find the small print.

```markdown
| # | Feature | Scenario | Stimulus | Check | Measure |
|:--:|---|---|---|---|---|
| 1 |  |  |  |  |  |
| 2 |  |  |  |  |  |
```

How it gets filled in, in the order that pays off:

1. **Read the spec and write one row for every sentence that starts with
   "when".** Still without thinking about the testbench: the scenario column
   comes from the spec, not from the code.
2. **Mark the ones that are not going to come out of random.** Those are your
   directed cases, and they are few — if they are many, the random is badly
   skewed.
3. **Fill in the check column.** If a row has nobody to check it, either you are
   missing a prediction in the scoreboard, or it is a protocol rule and an
   assertion goes there.
4. **Fill in the measure column last**, and that is where you write the
   `covergroup`. It comes copied from that column: one bin per row.
5. **Run, look at which bin stayed at zero, and go back to point 2.** That is
   *coverage closure*, and it is what a verification engineer spends the day on.

A plan filled in, with the five columns and the bins that get closed, is
something you can show in an interview. A testbench without a plan is a pile of
tests somebody is going to have to read to find out what they prove.
