<!-- es-sha: 6470e3766d2e -->
## The verification plan

#### *The most professional deliverable of the discipline, and the cheapest*

- It is a **table**. It gets written **before** the testbench — if it gets written
  after, it describes what the testbench already does instead of what the spec asks for
- It comes out of the spec you have just read, not out of the testbench that does not exist yet
- And it is what gets delivered: the day 7 capstone is handed in with the plan filled,
  which is exactly what gets handed in on a project

Note:
This is the slide that orders the whole course, and that is why it comes before the first
line of testbench. Everything that comes after —the stimulus, the scoreboard, the
covergroups, the assertions— are columns of this table.
It is worth saying it head on: the plan is not bureaucracy. It is the only serious
answer to *"are you done verifying yet?"*, and it is the first thing a technical
lead asks for when they ask how the block is going.
The empty template is in `docs/en/verification-plan.md`, and it gets used twice in
the course: here to read it, and on day 7 to fill it from scratch.

---

## The verification plan

#### *The five columns*

| Column | The question it answers | What does **not** go in |
|---|---|---|
| **Feature** | which part of the spec does this row come from? | the name of a testbench file |
| **Scenario** | which concrete situation has to be provoked? | *"test the ALU"* |
| **Stimulus** | who provokes it: the random or a directed case? | *"by hand"* |
| **Check** | who says it went right? | *"you look at the wave"* |
| **Measure** | which bin gets filled when it happens? | *"you see it in the log"* |

- One row per **scenario**, not per feature: a feature with three corner cases
  is three rows, and they get closed one at a time

Note:
It is worth reading the right-hand column out loud: they are the five mistakes people
make the first time, and all five sound reasonable when you write them.
The hardest column is the measure one, because it forces you to decide *beforehand* what
you are going to count. It is the one that on day 1 still cannot be filled —the bins do not
exist until the next unit— and that is why the plan gets filled as the
testbench grows.

---

## The verification plan

#### *Two rules that come out of the columns*

- **If the check column says *"by eye"*, the scenario is not verified.**
  It is *simulated*, which is another thing
- **If the measure column is empty, nobody is going to find out that the
  scenario never happened.** A case the random never touched and that has no bin is
  indistinguishable from one that happened a thousand times
- And one distinction that orders the check column: **the scoreboard checks
  *what* the DUT computes; the assertions check *how* it is talked to**

Note:
The difference between verified and simulated is who finds out when it fails at three
in the morning in the regression. If the check is a pair of eyes, nobody
finds out: the regression passes green with the bug inside.
The third bullet is a promise the course keeps on day 7: until then
every check is a scoreboard check, and half the protocol goes unchecked.
Worth saying now so that day 7 does not look like an add-on.
A serious plan has both columns, and the VTALU table —which is seen whole in
the next unit, already with the bins— has eight scoreboard rows and four
assertion ones.
