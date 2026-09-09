<!-- es-sha: 38096c3189a5 -->
## Exercise · Day 8

#### *Modelling the register map*

`cd code/ejercicios/d8-ral && cat README.en.md`
<!-- .element: class="comando" -->

- It is **literally** the first thing you get asked for in a project with registers: they
  give you the table of the spec and you give back the model
- The DUT and the testbench are the ones from the capstone. The adapter, the predictor and the
  tests come from the unit. **The only thing you write is `apb_reg_block.svh`**
- Four registers, six fields, forty lines
- The checker goes in stages: the **map** —printed and compared with the table, without
  simulating anything—, the **accesses** —the two sequences of the library— and **what the
  model cannot predict**

Note:
It is the shortest exercise of the fifteen and the one most like a real task from
the first weeks of a project. Forty lines, and half of them are copying and
pasting the pattern of `CTRL`.
The stage that teaches is stage 1, and for a reason of method: the model gets **printed**
—`+UVM_TESTNAME=mapa_test`— and gets compared line by line against the table of
`spec.en.md`, before simulating anything. It is what has to be done with a real register
model, where the typical mistake is not about UVM but an offset copied
wrong from a 200-row spreadsheet.
Stage 2 is where `CLR` falls: whoever declared it `RW` passes stage 1 without
a problem and finds out here, with the number of the bit, thanks to a test they did not
write. It is worth letting them fall there — it is the moment when the RAL argument
stops being an opinion.
And stage 3 is the one that separates: it asks you to **switch off** a check, which is the opposite of
what the course has been asking for the last seven days. The justification has to come
from them: `STATUS.EN` changed because of a write to another address, the model
cannot know it, and a false positive that gets let through ends up with somebody switching
the whole check off.
