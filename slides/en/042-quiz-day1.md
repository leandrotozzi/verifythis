<!-- es-sha: f6a4b6d74bdb -->
<!-- .slide: class="quiz" -->

## Review · Day 1

#### *1 of 6 · Trends*

**According to the Wilson 2024 study, where does most of a verifier's time go?**

- [ ] Into writing the testbench
- [x] Into debug
- [ ] Into running regressions
- [ ] Into writing the specification

> **Into debug** — 47 % of the verifier's time goes there. That is why the course devotes a whole section to reporting: a scoreboard that only says "failed" leaves you right inside that 47 %.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *2 of 6 · The ALU spec*

**While the VTALU is running an operation, what do `start` and the operands have to do?**

- [ ] `start` drops right away; the operands can change
- [ ] It makes no difference: the DUT registers them on the first edge
- [ ] The operands have to change on every cycle
- [x] `start` stays at 1 and the operands stable until `done` goes up

> **Stable until `done`** — it is the DUT protocol, and it is exactly the reason the BFM exists: to wrap that rule in a single place so that no test forgets it.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *3 of 6 · Functional coverage*

**The test runs 1000 random operations and the *code* coverage reads 100 %. What does that tell you about the verification?**

- [ ] That the DUT is verified
- [x] Very little: it says which RTL got **executed**, not which scenarios of the **spec** happened
- [ ] That the testbench has no bugs
- [ ] That the verification plan can already be closed

> **Very little** — code coverage measures the DUT; functional coverage measures the spec. A feature the designer never wrote gives 100 % of lines and 0 % of what matters, and the report is not going to tell you.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *4 of 6 · covergroup*

**You declare a `covergroup`, you `new()` it, you run a thousand operations and the report reads 0 %. What is the first thing to look at?**

- [ ] That the bins are badly defined
- [x] That nobody is calling `sample()`
- [ ] That the DUT is not answering
- [ ] That `ignore_bins` are missing

> **The `sample()`** — a covergroup does not sample itself: somebody has to call it, on the edge or when a transaction arrives. Without that call the code compiles, runs, and the report reads 0 without a single warning.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *5 of 6 · Interfaces and BFM*

**What does the testbench gain when the protocol moves into a BFM?**

- [x] The rest of the TB stops talking in signals and starts talking in operations
- [ ] It simulates faster
- [ ] The testbench becomes synthesizable
- [ ] You save having to declare a `clk`

> **It stops talking in signals** — the BFM translates *one operation* into *a handshake of signals*. The tester, the scoreboard and the coverage never touch a wire again: it is the first step towards UVM.

---

<!-- .slide: class="quiz" -->

## Review · Day 1

#### *6 of 6 · clocking block*

**Are clocking blocks needed to write a UVM testbench without races?**

- [ ] Yes: without a clocking block, driver and DUT always compete on the same edge
- [ ] Yes, and they are also part of the UVM library
- [x] No: NBA in the driver plus scheduler discipline is enough — they are an optional abstraction, useful above all in reusable agents
- [ ] No, and that is why they should never be used

> **They are not needed, and they are worth using anyway** — they belong to **SystemVerilog**, not to UVM. What avoids the race is understanding the scheduler: a driver that drives with `<=` against a DUT that registers with `<=` is already deterministic. The clocking block does not replace that understanding, it **wraps** it — and that is where it pays off: reusable agents, VIP, gate-level and protocols with setup/hold in the spec.
