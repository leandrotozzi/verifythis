<!-- es-sha: a4e9b3e529df -->
<!-- .slide: class="quiz" -->

## Review · Day 1

#### *1 of 7 · The question of the day*

**A thousand random operations, the scoreboard reported no error and the log ends in `PASS`. What are you missing to say the DUT is verified?**

- [ ] Nothing: a thousand operations without an error is a verified DUT
- [ ] Running more seeds until code coverage reaches 100 %
- [x] Knowing what the log would have said with a bug inside: run it with the mutated DUT
- [ ] Replacing the scoreboard with assertions, which check the protocol on the exact edge and not at the end

> **Watch it fail** — the `PASS` of a scoreboard that never saw an error says nothing: it may not have compared. `VTALU_BUG=1` flips one bit of the result and the testbench has to fail; `make mutante` demands it for the three testbenches of days 1 and 2.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *2 of 7 · The ALU spec*

**While the VTALU is running an operation, what do `start` and the operands have to do?**

- [ ] `start` drops right away: it is a start pulse, and the DUT already latched everything
- [ ] It makes no difference: the DUT registers them on the first edge
- [ ] The operands have to change on every cycle
- [x] `start` at 1 and the operands still until `done` goes up

> **Stable until `done`** — it is the DUT protocol, and it is exactly the reason the BFM exists: to wrap that rule in a single place so that no test forgets it. The first distractor describes a real protocol —pulse start, latched operands— that this DUT does not have.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *3 of 7 · Functional coverage*

**The test runs 1000 random operations and the *code* coverage reads 100 %. What does that tell you about the verification?**

- [ ] That the DUT is verified and the verification plan can be closed
- [ ] That the testbench has no bugs
- [ ] That few scenarios are missing: 100 % already walked the whole design
- [x] Very little: it measures the RTL that ran, not the spec

> **Very little** — code coverage measures the DUT; functional coverage measures the spec. A feature the designer never wrote gives 100 % of lines and 0 % of what matters, and the report is not going to tell you.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *4 of 7 · covergroup*

**You declare a `covergroup`, you `new()` it, you run a thousand operations and the report reads 0 %. What is the first thing to look at?**

- [x] That nobody is calling `sample()`
- [ ] That the bins are badly defined and match no value at all
- [ ] That the DUT is not answering
- [ ] That `ignore_bins` are missing

> **The `sample()`** — a covergroup does not sample itself: somebody has to call it, on the edge or when a transaction arrives. Without that call the code compiles, runs, and the report reads 0 without a single warning.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *5 of 7 · Interfaces and BFM*

**What does the testbench gain when the protocol moves into a BFM?**

- [x] It stops talking in signals and starts talking in operations
- [ ] It simulates faster: one BFM task costs the simulator less than moving wires
- [ ] The testbench becomes synthesizable
- [ ] You save having to declare a `clk`

> **It stops talking in signals** — the BFM translates *one operation* into *a handshake of signals*. The tester never touches a wire again; the scoreboard and the coverage keep reading them, through the interface, until a monitor sends them transactions. It is the first step towards UVM.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *6 of 7 · The verification plan*

**In the verification plan, what goes in the *Measure* column?**

- [ ] How long the scenario takes to run, so the regression can be estimated
- [ ] The name of the testbench file that covers that row
- [x] Which bin gets filled when the scenario happens
- [ ] How many times the test has to be run to call it covered

> **Which bin gets filled** — the five columns are *Feature*, *Scenario*, *Stimulus*, *Check* and *Measure*, and this is the one that costs the most: it forces you to decide **beforehand** what is going to be counted. If it is left empty, nobody is going to find out that the scenario never happened — a case the random never touched and that has no bin is indistinguishable from one that happened a thousand times.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *7 of 7 · clocking block*

**Are clocking blocks needed to write a UVM testbench without races?**

- [ ] Yes: without a clocking block, driver and DUT always compete on the same edge
- [ ] Yes, and they are also part of the UVM library
- [x] No: NBA in the driver plus scheduler discipline is enough
- [ ] No: the `uvm_driver` replaces them, since it already samples in the right region

> **They are not needed, and they are worth using anyway** — they belong to **SystemVerilog**, not to UVM, and no `uvm_driver` samples for you. What avoids the race is understanding the scheduler: a driver that drives with `<=` against a DUT that registers with `<=` is already deterministic. The clocking block does not replace that understanding, it **wraps** it — and that is where it pays off: reusable agents, VIP, gate-level and protocols with setup/hold in the spec.
