<!-- es-sha: 4c8ceb7be78e -->
## Capstone · Day 7

#### *The whole testbench, from a blank sheet*

`cd code/ejercicios/d7-final && cat spec.en.md`
<!-- .element: class="comando" -->

- The other twelve exercises gave you a file with a hole in it. This one gives a **DUT,
  a spec and nothing else**
- The DUT is not the VTALU: it is an **APB3 slave** with four registers. It has
  addresses, two phases per transfer, a *wait state* and an error response
- Everything gets written: the interface with the protocol, the transaction, the driver, the
  monitor, the agent, the scoreboard, the covergroup, the sequences and the tests
- The checker goes **in stages**, and each one prints its `STAGE N OK`. It can be
  finished one at a time — and that is the way to do it

Note:
It is the afternoon of day 7 and it is the exercise that justifies the whole course. It is worth
saying it that bluntly: up to here the student has completed somebody else's structure, which is
exactly what they are going to be asked for on the first day of a real project — but
they have never built one. The difference between *"I did the course"* and *"I know how to do it"* is this
afternoon.
If the group is short of time, stage 1 —the monitor— on its own already leaves something: it is the
deliverable the bus appendix recommends as the first one, and it gets done in half
an hour.
The other use, for whoever is studying alone: it is the exercise that can be shown in
an interview. A UVM testbench on an APB, written from scratch, with its
coverage plan, is exactly the example they ask for.

---

## Capstone · Day 7

#### *The DUT: four registers and the small print*

| Addr | Name | Access | Contents |
|---|---|:--:|---|
| `0x00` | `CTRL` | RW | bit 0 = `EN` · bit 1 = `CLR`, **autoclear** |
| `0x04` | `SCRATCH` | RW | 32 bits, and **adds to `ACC` if `EN`** |
| `0x08` | `ACC` | RO | the accumulator |
| `0x0C` | `STATUS` | RO | bit 0 = `EN` · bit 1 = `OVF`, sticky |

{{code:code/ejercicios/d7-final/rtl/apb_regs.sv|lines=35-46}}

- The read puts in **one wait state**: the driver waits for the handshake, it does not count cycles
- From `0x10` upwards, `PSLVERR`. Writing an RO, on the other hand, is **not** an error

Note:
The four traps of the spec are put there on purpose and all four are about
a spec badly read, not about UVM: the wait state of the read, the `CLR` that never gets read
at 1, the read-only register that gets written without giving an error, and the accumulator
that only runs with `EN=1`. They are the four that hang the first testbench, and
they are together in a section of `spec.md` called *The small print* — in
a real spec they are not going to be together nor in a section with that name.
The `assign` of the `PREADY` is the whole slide if one has to be picked: it says that the
write does not wait and the read does, and out of that comes the `do @(posedge PCLK); while
(!PREADY);` of the driver. A driver that takes for granted that ACCESS lasts one cycle reads
`PRDATA` one cycle too early — and it does not fail every time, which is the worst that
can happen.

---

## Capstone · Day 7

#### *The order: monitor, driver, scoreboard, coverage*

- **1 · The monitor.** The `top.sv` brings **two** slaves: one for your testbench and
  another driven by an ordinary module, without UVM. A **passive** agent on that one, and
  let us see the eight transfers. Without a driver
- **2 · The driver.** The protocol inside the interface, and a directed
  sequence that writes and reads the four registers
- **3 · The scoreboard.** The DUT modelled in software. The checker runs it twice:
  against the healthy DUT it has to keep quiet, and with **`+BUG=1`** it has to scream
- **4 · The coverage.** The covergroup with the seven rows of the verification
  plan of the spec: more than 20 points, 90 % covered

Note:
The order is not a whim of the checker: it is the field advice of the appendix
*From the VTALU to a real bus*. The first thing that gets written is the monitor, because
whoever starts with the driver writes stimulus nobody is watching and discovers a
week later that their monitor does not reconstruct. That is why the `top.sv` comes with the second
slave: so the monitor has something to watch **before** the driver
exists.
Stage 3 is the one that gets discussed the most and the one that pays off the most: a scoreboard that has never
seen an error is not tested. `+BUG=1` takes the `CTRL.EN` gate off the DUT, so
the accumulator always adds. A model that has not modelled `EN` passes both
runs and the checker catches it — which is exactly what a regression
with a mutation test would do.
And a hint about shape for stage 3, which saves a rewrite: the APB answers
**in order and one at a time**, so a queue is enough and the scoreboard can compare
on the spot. It is worth writing that assumption down in the plan like any
other, because it is the first one that falls over when the DUT stops being a simple
slave: there the pattern is the table indexed by ID of the analysis ports.
And stage 4 closes the circle of day 6: the covergroup does not get invented, it gets copied
from the table of the verification plan. If a bin is left at zero, there is a row of the
plan that was not verified — no matter how green the scoreboard is.
