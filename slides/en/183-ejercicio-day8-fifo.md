<!-- es-sha: 5bd74e6de67b -->
## Capstone 2 · Day 8

#### *The second final: a FIFO with backpressure*

`cd code/ejercicios/d8-fifo && cat spec.en.md`
<!-- .element: class="comando" -->

- For whoever has already handed in the APB. **The protocol is simpler** —there are no
  addresses, no wait states, no error response— and even so it is harder
- The APB one is a slave **with no useful memory**: an address and a value, and the
  scoreboard can be a table of four rows. A FIFO has **order** and
  **occupancy**, and both have to be carried
- The bug of `+BUG=1` is not a data bug: `almost_full` goes up **one place late**.
  The data still comes out right and in order, so a scoreboard that only
  compares `rd_data` passes green
- The small print: the flags describe the state **before** the edge,
  `rd_data` arrives **one cycle late**, writing with the FIFO full is **not an
  error**, and a simultaneous read **makes room** for the write

Note:
This is the exercise that separates whoever understood from whoever copied the pattern, and the
mechanism by which it separates is in the third bullet: the bug is in a **control
output**, not in the data path. A scoreboard that compares what
comes out of `rd_data` closes six of the seven rows of the plan and passes green
with the DUT broken. To see it the flags have to be predicted, and to predict the
flags the occupancy has to be modelled — that is, writing a reference model
with state, which is what the first capstone could not ask for.
It is worth saying why it goes second and not first: the APB is the DUT you run into in the
first year, and the table-address-value pattern is the right one there. This one teaches
when that pattern stops being any use, and that lesson is not understood without having used
the pattern before.
The trap that catches the most people is the order of updating the model: first look
at whether the read takes something out —that frees a place— and only then whether the write goes in.
The other way round, the simultaneous write with the FIFO full shows up as a lost piece of data
that the DUT never lost, and the student spends an hour looking for the bug in the RTL.
And the second one: the `check_phase` that claims data that never came out. Almost
always the test ended one cycle too early, and it is the `drain_time` of day 3
showing up where nobody expected it.
