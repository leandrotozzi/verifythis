<!-- es-sha: e198e9427073 -->
## Interfaces and BFM

#### *First: the signals stop being loose*

{{code:code/u2/interfaces-bfm/vtalu_bfm.sv#signals-and-clock}}

- An `interface` is a **bundle** of signals with a name of its own. Nine wires that
  used to be declared in the `top` now live together
- The clock gets generated inside: the interface is not a wire, it is a model of the bus
- Connecting the DUT becomes `.A(bfm.A)`, `.clk(bfm.clk)`… and a new signal gets
  declared **once**: the modules that use it see it appear without touching their ports
- What is not needed here and you will see in somebody else's RTL: the **`modport`**, which is
  the same interface with the directions set for one side of the wire

Note:
First step towards UVM and it does not have a single line of UVM.
The immediate gain is a maintenance one and it is worth measuring: with loose
signals, splitting the testbench into modules forces every one of them through every
port list, and a new signal gets wired in all of them. Here it gets declared in the
interface, and the only port that changes is the DUT's.
One detail of types that costs you: `op` is a `wire [2:0]` and `op_set` is the
`operation_t`. The `assign op = op_set` is the bridge between the testbench enum and
the DUT wires. It is the only place in the course where the seam between the
two worlds is visible.
And the `modport`, which does not show up in the rest of the course and does in anybody
else's RTL: it is a view of the interface with the directions declared —`modport dut (input
A, input B, output result)`—, and the module asks for it in its port list
(`vtalu_bfm.dut bus`). It is good for two things, and both are worth it: it lets the compiler
stop the DUT if it writes a signal that was an input as far as it is concerned, and it lets whoever reads the
interface know who drives what without opening the RTL. It is not here because the BFM belongs
to the testbench and drives everything; at work the interface almost always comes with
two or three modports and what you need to know is which one to ask for.

---

## Interfaces and BFM

#### *Then: the protocol hides inside a task*

{{code:code/u2/interfaces-bfm/vtalu_bfm.sv#send_op}}

- `send_op(A, B, op, result)` translates *"do an addition"* into the signal wiggling
  the DUT expects. That is a **Bus Functional Model**
- Inside it is all the fine print of the spec: the `reset_n` pulse, the
  `no_op` that does not wait for `done`, and the `do ... while (done == 0)` of the rest
- From here on **nobody moves `bfm.start` by hand**. Whoever wants an
  operation asks for it

Note:
The sentence that orders the section: the protocol gets written **once**. If tomorrow
the DUT asks for two cycles of `start`, this task gets touched and nothing else.
The `#1` after the `@(posedge clk)` is the same precaution as the scoreboard of the conventional testbench: moving the signals one delta after the edge, not on the edge.
And the hook for day 4: the `driver` of the put and get ports is exactly this task,
but inside a class and fed by a port. The operation —hiding the
wire— is the same; what changes is where the data comes from.

---

## Interfaces and BFM

#### *The top, with the BFM in the middle*

- The testbench is still split into the same three pieces —tester, scoreboard and
  coverage—, and not one of them changed its name
- What changed is **how they connect to the DUT**: there are no loose signals
  travelling any more, there is a single interface the three of them share

{{code:code/u2/interfaces-bfm/top.sv}}

Note:
It is worth reading this `top.sv` next to the previous section's, because the diff is
the whole section: where there was a list of `logic` declared in the top and
wired by hand to the DUT, now there is **one line** that instantiates the BFM and one that
plugs it in.
What has to be pointed out, because it is what repeats for the rest of the course: the DUT
connects to `bfm.A`, `bfm.B`, `bfm.op`… The interface is not an abstract object,
it is the same old wires grouped under a name. Nothing became slower
or stranger — it became harder to connect wrong.
And the detail that pays for itself the day the DUT grows: adding a signal to the
protocol means touching the interface, and everyone who uses it sees it appear. In the
previous version you had to remember to wire it in every instance.

---

## Interfaces and BFM

#### *Scoreboard: the same check, now talking to the BFM*

{{code:code/u2/interfaces-bfm/scoreboard.sv}}

- It is the conventional testbench's `scoreboard`: it predicts and compares with the
  same logic
- The only thing that changed is where it gets the signals from: they used to be variables of the
  same module, now they are `bfm.A`, `bfm.B`, `bfm.op_set`
- And that is why it is a **separate module** now: it can live in its own file
  because it shares nothing with the tester except the interface

Note:
What has to be pointed out is what did **not** change. The verification logic is
identical; what got modularized is the wiring. That is the whole section.
The `bfm.` in front of every signal is the first time the student sees an interface
hierarchy, and it is worth writing it on the board: `top.bfm.A`. In the tests that
same reference is going to arrive through the config_db into a class, and there the prefix will
be a handle instead of an instance name.
The debt that stays open: the scoreboard still watches the signals
directly. Only in the analysis ports is it going to receive *transactions* from a monitor and
stop knowing that a `clk` exists.

---

## Interfaces and BFM

#### *Tester: it asks for operations, it does not move wires*

{{code:code/u2/interfaces-bfm/tester.sv#stimulus-loop}}

- The tester no longer touches `start` or waits for `done`: it calls `bfm.send_op(...)` and
  forgets about the protocol
- The handshake ended up **written once**, inside the BFM. If tomorrow the
  DUT asks for two cycles of `start`, one file gets touched
- That is the definition of *Bus Functional Model*: the task translates *"do an
  addition"* into the signal wiggling the DUT expects

Note:
The comparison with the conventional testbench is the slide: over there the `tester` raised `start`,
waited for `done` and lowered `start`, mixed in with the stimulus generation. Here
it only generates stimulus.
Worth counting how many places of the conventional testbench knew about the protocol
—the tester and the scoreboard— and how many move `start` now: one, the `send_op`.
The scoreboard still waits for `done` on its own; that debt gets paid by the monitor
of the analysis ports.
And the hook for day 4: in the put and get ports this same tester is going to be a class with
a `put_port`, and the BFM is going to end up on the other side of a driver. The operation is
the same one we did here —hiding the wire— repeated one level up.

---

## Interfaces and BFM

#### *The protocol rule, written in the simulator's language*

```sv
// IMMEDIATE: a statement. It checks the present, where the thread goes by.
assert (op_set != no_op || done == 0)
   else $error("no_op should not raise done");

// CONCURRENT: a declaration with a clock. It plugs itself in once and
// checks EVERY edge of the simulation, on its own, forever.
a_operandos_estables :
assert property (@(negedge clk) start |=> $stable(A) && $stable(B));
```

- The rule —*while `start` is up, the operands are not touched*— is already
  written **twice**: in prose in the spec, and wrapped inside
  `send_op()` here
- An **assertion** is that same sentence a third time, but **executable**: it does not
  respect it, it **checks** it
- And it checks it where it happens —in the interface, on the exact edge— and not at the end,
  comparing results

Note:
This is a hook, not the section: the syntax must not be explained here, and least of all
the `|=>` or the edge. The only thing that has to stick is that the protocol rule
can be written in a form the simulator understands.
Worth pointing out the asymmetry that opens up: the BFM **complies with** the protocol, and that
is enough while all the stimulus goes through the BFM. As soon as a legacy module,
a VIP from another team or a driver written in a hurry shows up, complying stops
being the same as checking.
If somebody asks why one says `negedge` and the other does not, the short answer
is *"because the BFM writes on the negedge, and that is only fully visible in the assertions"*. That is the question we want to plant.

---

## Interfaces and BFM

#### *Where each thing gets checked*

- The conventional testbench's **scoreboard** checks the **result**: `A op B` against what
  the DUT returned. It is the half this course develops to the end
- An **assertion** checks the **protocol**: who moves, when, and for
  how many cycles. It is the other half
- A DUT that returns `result` correctly but drops `done` one cycle early **passes
  every test** of the next six days. Nobody is watching it
- It is seen whole in **the assertions section**, with the same VTALU and the same `run.sh`

Note:
The sentence worth leaving on the board for the whole course: *the scoreboard
checks what the DUT computes; the assertions, how it is talked to.* The three
sections left of day 1 and the six days that follow are the first half;
the second arrives at the end, and it arrives on this same example.
There is no need to promise more than that. The assertions come back with the property of this
slide, write it for real, and show why the edge chosen is not a
detail.

---

## Interfaces and BFM

#### *The hole the BFM leaves: the timing*

{{code:code/u2/clocking/sin_clocking.sv#three-samples}}

- The BFM wrapped **the protocol**. What it did **not** wrap is *when* it
  drives and *when* it samples: that is still decided task by task
- Three ways of reading the same data: `0`, `11` and `11`. Two values, but **three
  mechanisms**, and the middle one depends on a `#1` that is visible nowhere
- The `@(negedge clk)` of our BFM is the third one. It works — and it asks whoever
  reads it to know why

Note:
Run this live, it takes two seconds: `make u2/clocking`. The three lines
it prints are the whole slide.
The first one is the surprising one and it is worth explaining slowly: sampling **on**
the `posedge` gives the **old** value, because the DUT's `always_ff` updates with
a nonblocking assignment and that one lands after this `initial` already
ran. It is not a Verilator bug and not an oddity: it is the LRM region order,
and it is the same on Questa.
The second one is the worst of the three, and it is the one to mark as a silent trap:
it works, and it works **by accident**. The `#1` does not say which problem it solves,
it is not documented, and the day somebody deletes it because "it did nothing" the
testbench keeps compiling and starts lying. It is the same `#1` as the scoreboard of
the conventional testbench, and the difference is a single one: there the slide says
which race it avoids. An explained `#1` is a patch that knows it is a patch; a loose
`#1` is the trap.
And the third is ours. Worth being honest with the group: the course drives on
`negedge` and samples on `posedge` because it is the trick you can understand without having
seen clocking blocks, not because it is what gets written on a project.

---

## Interfaces and BFM

#### *Why the edge alone is not enough: the regions*

![The regions of an edge: Preponed, Active and NBA, and the three samples](res/diagrams/en/interfaces-bfm_regiones.svg)
<!-- .element: class="grande" -->

- An edge is not an indivisible instant: inside it there are **regions**, in order
- The `<=` of the `always_ff` **lands in NBA**: whoever reads in *Active* reads the old value
- The `#1` crosses the NBA, the opposite edge crosses it with room to spare, and
  SVA needs neither of the two: it samples in *preponed*, before everything

Note:
This figure is the one to leave on screen while reading the three samples of the
previous slide. Without it the explanation is *"the old value"*, which sounds like
a quirk of the simulator; with it, it is a consequence of the order, and the order
is in the LRM.
The scheduler has more regions than the four in the drawing —`docs/clocking-blocks.md`
lists them all— but these are enough to explain the three cases, and adding the
others changes no answer.
The question worth asking the group before showing the answer: if the DUT writes in
NBA and your `initial` wakes up in Active, which one runs first? That is where it
shows on its own why sampling **on** the edge gives the value from before.
And the hook with day 7: the amber bar on the left is the region where SVA samples.
It is the same figure that explains why an assertion does not check what happened
but what it saw, and why the `@()` you give it changes the result.

---

## Interfaces and BFM

#### *The clocking block: the edge and the delta, declared once*

{{code:code/u2/clocking/con_clocking.sv#reg_bfm}}

- `input #1step` — sample the value **stable just before** the edge, which is
  the one the hardware sees. Never the one the nonblocking assignment just wrote
- `output #0` — drive **on** the edge, with the nonblocking assignments, so the DUT does not
  see it until the next edge
- Driving becomes `cb.d_in <= value`; sampling, reading `cb.d_out`; waiting,
  `@(cb)`. **No `#1` in any task**
- And the value read is the same at any point of the cycle: the race got
  closed by declaration, not by habit

Note:
This is the slide you have to be able to repeat in an interview, because
`clocking block` is one of the first things people get asked and the good answer
is not "it synchronizes": it is **it declares the sampling and driving instant once,
in the interface, so that no task picks it again**.
The detail that confuses and is worth previewing: in the example you need **three**
`@(cb)` to see the 11, and not two. One for the `output #0` to put the data,
another for the DUT to take it, and the third because the `input #1step` samples what is
stable **before** the edge. The arithmetic is in plain sight in the code and does not
depend on the simulator — which is exactly the difference with the `#1`.
If somebody asks why the course does not use it from day 1: because to
understand which problem it solves you have to have had the problem. Only now,
with the BFM written and the three lines running, does the question make sense.
Verilator supports it since 5.x and the example ends in `$fatal` if the
sampling stops giving 11: it is the net that warns if a release changes the semantics.

---

## Interfaces and BFM

#### *Are they mandatory? No — and it is worth knowing why*

| The question | The answer |
| --- | --- |
| Can a correct TB be written **without** clocking blocks? | **Yes.** With NBA in the driver and scheduler discipline, there is no race |
| What should **a team** use? | **Use them** on synchronous interfaces — it is what the lowRISC/OpenTitan style guide says |

- They are not UVM's: they are **SystemVerilog's**. UVM neither asks for them nor knows them
- **Dave Rich** —the reference at Verification Academy— has held since 2014 that
  they are *optional*: what avoids the race is understanding the scheduler, not the
  clocking block
- The two positions answer different questions: one is **language
  correctness**, the other is **team policy**. Both are right

Note:
This slide is the one that keeps the course from lying by simplifying, and it is worth
spelling out: *"always use clocking blocks"* is a style rule,
not a theorem. Whoever repeats it as if it were the latter is in for an
uncomfortable argument with the first senior they run into.
Dave Rich's sentence that orders the topic —and it is worth quoting verbatim— is from 2014:
*"If you are already familiar with Verilog testbenches, then you probably don't
need them."* He held it in 2022 and in 2024. It does not say they are wrong: it says they are not
a **necessary condition**.
And on the other side is lowRISC, which in OpenTitan's DV Coding Style Guide makes them
mandatory for synchronous signals. They do not contradict each other: Dave answers
*"can I?"* and lowRISC answers *"what do we all do here?"*. It is exactly the
difference between well-used `malloc`/`free` and a style guide that mandates
smart pointers — an expert being able to manage memory by hand does not make
RAII useless.
Where they really move the needle, and this is what to retain: **reusable** agents and VIP
—whoever writes them is far from whoever uses them—, gate-level
with SDF, and protocols where the spec defines setup/hold. There they stop being style.
The long material, with the sources, is in `docs/clocking-blocks.md`.

---

## Interfaces and BFM

#### *The price: two names for the same wire*

{{code:code/u2/clocking/mezcla.sv#two-reads}}

- With the signal inside a clocking block there are **two** ways of reading it:
  `bfm.d_out` is the live wire, `bfm.cb.d_out` is what got sampled
  `#1step` before the edge
- On a signal that changes every cycle they **differ by one cycle**: the example
  prints `3` and `4`, at the same instant and on the same wire
- Nobody warns you. It compiles, it runs, and the scoreboard fails **only when the data
  changes**
- The rule: if a signal went into the clocking block, **the whole protocol reads it
  through there** — and you wait on `@(bfm.cb)`, not on `@(posedge bfm.clk)`

Note:
This is the flip side of the previous slide and the reason the course does not use
them in its BFM: used badly they are **worse** than not using them, because
the failure mode is intermittent and the waveform looks fine.
The real mistake, the one that shows up in the forums, has two shapes and it is worth
naming both. One is mixing the event: `@(posedge vif.clk)` and then reading
`vif.cb.foo`. The other is mixing the access: the monitor reads `vif.cb.data` and the
scoreboard —or an assertion, or a debug `$display`— reads `vif.data`. Both
end the same way: two temporal views of the same wire, and a mismatch that
shows up once every twenty runs.
Worth running the example and leaving the number in plain sight: `3` and `4`. Nobody argues
with a `3` and a `4` on the same wire.
And the moral that hooks into the silent traps appendix, where this one
is written down: in verification the expensive error is not the one that breaks, it is the one that
lies. A half-done clocking block lies.

---

## Interfaces and BFM

#### *Summary of the unit*

- An `interface` is a **bundle of named signals**: adding a wire stops
  being touching six port lists
- A **BFM** is the interface **plus the protocol**: `send_op(A, B, op, result)`
  translates *"do an addition"* into the signal wiggling
- All the fine print of the spec —the reset pulse, waiting for `done`, the
  `no_op` that does not answer— ends up written **once**
- From here on **nobody moves `bfm.start` by hand**. Whoever wants an operation
  asks for it
- The tester, the scoreboard and the coverage become **separate modules**, each
  one in its file, connected by the BFM
- And this does not get abandoned: the agent's driver keeps calling
  **this same task**
- The rule the BFM **complies with** can also be **checked**, with an assertion
  that lives in this same interface. That is the assertions section
- And the **`clocking block`** closes the last hole: the edge and the delta
  stop being decided task by task and get declared **once**

Note:
This is the most important section of day 1 and the one that looks least like it. Everything that
comes after —classes, factory, agents, sequences— rearranges pieces **above**
this line. The line itself never gets touched again.
The short way to say it: from here on the testbench stops talking in
wires and starts talking in operations. That is the first step towards UVM, and it is
already taken, without having written a single class.
If the group comes from RTL, the analogy closes on its own: the BFM is to the testbench what
a device driver is to the operating system.
