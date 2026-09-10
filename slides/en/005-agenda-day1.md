<!-- es-sha: 8ed5ce2170ab -->
<!-- .slide: id="day1" data-machete="res/diagrams/en/wave-dut.svg|VTALU protocol: start and operands stable until done,res/en/TB.svg|Anatomy of a SystemVerilog testbench: the DUT, the tester, the scoreboard and the interface" -->

<!-- .slide: data-transition="concave" -->

## Agenda

#### *Day 1 · ≈ 4 h · units 1 and 2*

**Unit 1 · Why we verify**

- Trends
- What UVM is
- The VTALU spec
- The verification plan

**Unit 2 · The testbench without UVM**

- The conventional testbench
- Functional coverage
- Interfaces and BFM · the `clocking block`

**Two exercises**, and the second one is solved with the wave viewer

**By the end of the day you can:**

- **Write** a five-column verification plan for a DUT you have not seen before
- **Read** the number a `covergroup` gives, and say what to look at first when it
  reads 0 %
- **Explain** which race a `clocking block` avoids — and why they are optional
  anyway

Note:
The three verbs below are the contract of the day, and it is worth reading them
out loud before starting: on video they are the ten seconds in which somebody
decides whether this is the one they were looking for. They are rows 2, 4 and 5
of the closing self-assessment, brought to the front; whoever can answer them at
the end of the day does not need to look at anything else.
And an honest warning for whoever comes from VHDL or from Verilog-2001, which is
the declared audience: day 2 levels the OOP, but **nobody levels SystemVerilog**,
and today `interface`, `logic`, `enum`, `package`, `covergroup`, `clocking` and an
`assert property` all show up. It is all on one page in
**`docs/systemverilog-para-el-que-viene-de-vhdl.md`** (in Spanish): half an hour
before starting, and day 1 stops having two steps at once.
