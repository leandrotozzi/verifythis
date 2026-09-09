<!-- es-sha: 83d81dad101f -->
<!-- .slide: class="quiz" -->

## Review · Day 7

#### *1 of 5 · Immediate and concurrent*

**What is the underlying difference between `assert(x.randomize())` and `assert property (@(posedge clk) …)`?**

- [ ] None: the second is syntactic sugar for the first
- [ ] The first can be switched off from the command line and the second cannot
- [x] The first is a **statement** that runs when the thread goes past it; the second is a **declaration with a clock** that gets evaluated on every edge, on its own
- [ ] The first is only valid inside a class and the second only inside a module

> **Statement against declaration** — the immediate one is to an `if` what the concurrent one is to an `always_ff`: one executes, the other gets instantiated. That is why only the concurrent one can describe something that lasts several cycles.

---

<!-- .slide: class="quiz" -->

## Review · Day 7

#### *2 of 5 · `|->` against `|=>`*

**The `done` of the VTALU comes out of an `always_ff`. Which implication goes in `start |?? done`?**

- [ ] `|->`, because the antecedent and the consequent belong to the same transaction
- [x] `|=>`, because what gets written with `<=` on edge *n* is only read on *n+1*
- [ ] Either of the two: the difference is a matter of style
- [ ] Neither: for registered signals you have to use `$past()`

> **`|=>` when the consequent comes out of a `<=`** — because `|=>` *is* `|-> ##1`, and the question to ask is how many edges later the spec promises it. With `|->` against a registered signal the property does not pass vacuously: it **fails on every transaction**, because it compares against the old `done`. The one that passes quietly is the one whose antecedent never occurs — which is why it always goes with its `cover property`.

---

<!-- .slide: class="quiz" -->

## Review · Day 7

#### *3 of 5 · The sampling edge*

**All the properties of the VTALU sampled on `@(posedge clk)` give 145 errors over 1000 operations, and the DUT is healthy. Why?**

- [ ] The `disable iff (!reset_n)` is missing
- [ ] The `posedge` is too fast: the clock has to be divided
- [x] The BFM writes the stimulus **on the `negedge`**, and on two consecutive `no_op` `start` goes down and comes back up between two `posedge`: the sampling does not see it go down
- [ ] Covergroups and assertions cannot share the same clock

> **An assertion is worth what its sampling is worth** — the stimulus gets sampled where the stimulus gets written. Stimulus on `negedge`, response of the DUT on `posedge`: zero errors. With a single clock there is no way.

---

<!-- .slide: class="quiz" -->

## Review · Day 7

#### *4 of 5 · The assertion that checks nothing*

**An `assert` property reports 0 failures during the whole regression. What do you know?**

- [ ] That the rule it describes holds
- [ ] That the DUT is free of protocol bugs
- [x] Nothing yet: its antecedent may never have occurred, or `--assert` may be missing and it is not even being evaluated
- [ ] That the property has a badly written `disable iff`

> **Zero failures and zero evaluations look the same** — that is why every assertion goes with its `cover property`: it is the only check of the check. In the section, `c_mult_3ciclos` stays at 0 and gives away that the real latency is four edges, not three.

---

<!-- .slide: class="quiz" -->

## Review · Day 7

#### *5 of 5 · Assertion or scoreboard*

**The DUT gives back the right `result` but drops `done` one cycle earlier than the specification says. Who catches it?**

- [ ] The scoreboard, when it compares the result
- [ ] The functional coverage, because the `done` bin is left empty
- [x] An assertion in the interface: it is a **protocol** bug, and the monitor has already erased the time before the transaction reaches the scoreboard
- [ ] The `uvm_fatal` of the `command_monitor`, which would stop seeing commands

> **Protocol → assertion. Data → scoreboard** — and it is not a preference: by the time the transaction reaches the scoreboard, the protocol is no longer there. Writing the check there would be rebuilding by hand the time the monitor has just erased.
