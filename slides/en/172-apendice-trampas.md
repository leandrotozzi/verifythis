<!-- es-sha: 0c261c51b6f1 -->
<!-- .slide: id="apendice-trampas" -->

## Appendix · The 21 silent traps

#### *It compiles, it runs, and it lies*

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The coverage gives **0 %** | the `new()` or the `sample()` of the covergroup is missing | one `sample()` per transaction, in the subscriber | Functional coverage |
| The daughter runs the method of **the mother** | without `virtual`, SV resolves by the **type of the variable**, at compile time | `virtual` on every method somebody is going to extend | Polymorphism |
| The component reads **somebody else's config** | `get(null, "*", …)` gives back the first thing that matches | `get(this, "", …)`, and `+UVM_CONFIG_DB_TRACE` | Tests |
| The test passes with **the wrong stimulus** | the `set_type_override()` arrived **after** the `create()` of the env | the override first, always. `+TOPOLOGY` gives it away | The env |
| The register model goes **green** and the field was never tested | the access starts with `WO`: `bit_bash` skips it and `do_check` drops it from the mask | if the field is readable, `WC` or `W1C`. `WO*` only if it really is not | RAL · d8 |

- None of these five gives a warning. None leaves the regression in red. All of them
  get discovered weeks later, or do not get discovered

Note:
This appendix is the one to print out and stick next to the monitor. They
are spread over seven sections because each one shows up when the
concept shows up, but they are needed together — and they are needed at the worst moment.
The thesis of the appendix is in the subtitle, and it is worth stating it as a general rule
of the craft: **in verification, the expensive mistake is not the one that breaks, it is the one that
lies.** A compilation error costs two minutes. A testbench that passes
measuring the wrong thing costs a tape-out.
The fourth row is the one that hurts the most in a big team, because whoever commits it
is not the one who suffers it: somebody adds an override in their test, somebody else moves
the `create()`, and the stimulus changes without anybody touching the stimulus file.
That is why the `+TOPOLOGY` of the agents is so cheap: it is ten seconds of reading
the tree UVM actually built, against the one you drew in your head.

---

## Appendix · The 21 silent traps

#### *The one publishing and the one listening*

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The subscriber counts **0** and the monitor prints 1000 | the `connect()` in the `connect_phase` is missing | cross-check it: against what the one that already worked says | Analysis ports · d4 |
| The monitor **never publishes**, and the scoreboard screams | `bfm.command_monitor_h = this` is missing in the `build_phase` | the `uvm_fatal` shows up in the class that is **not** to blame | Analysis ports |
| The copy **loses the fields of the mother** | a `do_copy()` that does not call `super.do_copy(rhs)` | every `do_copy()` calls the one above first | Hierarchies |
| Two different transactions **compare equal** | `super.do_compare()` called on a loose line and thrown away | chained with `&&`, never loose | Transactions |

- The four have the same shape: **the one that fails is not the one that got it wrong.** That
  is why the first reflex —opening the file that screamed— is the wrong reflex

Note:
The `bfm.command_monitor_h = this` row is the one that teaches the pattern best, and
it is worth telling it as a story: whoever forgets that line sees a `uvm_fatal` from the
scoreboard, opens the scoreboard, and the scoreboard is perfect. The monitor —which is
the one that got it wrong— says absolutely nothing, because its `always` in the
interface never called it.
The rule that comes out of there, and that holds for all four: when something screams, go up a
layer. The one that reports a mismatch is the last of the chain; the bug is almost always
in the one feeding it.
The last two are the ones from the *deep operations* of the class hierarchies and it is worth
pointing out the asymmetry: `do_copy()` without `super` loses data in silence;
`do_compare()` without `&&` compares too few of them, and gives back *equal* for two objects
that are not. The second is worse, because it switches off the whole scoreboard without switching it off.

---

## Appendix · The 21 silent traps

#### *Stimulus, scope and objections*

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The edge bins **never get filled** | `dist` with `:=`: the weight goes to **each** value of the range | measure the histogram **once**, with `:/` | Constrained random |
| The `randomize()` **does not run** with the asserts switched off | `assert(x.randomize())` — `assert` is a simulation directive | `if (!x.randomize()) uvm_fatal(…)` | Constrained random |
| Under the override, **some** transactions are of the old type | a `new()` where a `type_id::create()` belonged | what goes through the factory is what gets created with `create()` | Transactions |
| **Both agents** start up the same | two `set()` with scope `"*"`: the second overwrites the first | the scope is the **path** of the one that reads, with `*` at the end | Agents · d6 |
| The agent starts up **active** even though you set `is_active` in the `config_db` | the missing `super.build_phase()`: the one that reads it is `uvm_agent` | either a config object, or `super` — never half of each | Agents |
| The simulation **never ends** | an `item_done()` that was not called | `+UVM_TIMEOUT=5000000,NO` first, the trace after | Agents |
| It ends at **t=0** and says PASS | nobody raised the objection around the sequence | `+UVM_OBJECTION_TRACE` | Sequences |

Note:
The last two are the only ones on the list that do make noise — one hangs and
the other ends oddly — and they are here because the noise they make does not point at the
culprit. A hang does not say what was left waiting; a t=0 says PASS, which is
worse than an error.
The one about `assert(randomize())` deserves being told in full because it is the one most badly
copied from the internet: `assert` is not a function, it is a directive, and a simulator with
asserts disabled **does not execute the argument**. Which means the randomize
simply does not happen, the transaction gets sent with the previous values, and the
testbench carries on as if nothing had happened.
The one about the `new()` that eats the override is the subtlest of day 5, and it is worth
showing the number: in `add_test`, two of the transactions of the testbench were
built with `new()` and therefore were **not** `add_transaction`. Nobody
found out, because the scoreboard compared fine all the same.
And a closing recommendation for whoever is studying alone: read this appendix now and
again on the day something does not work. The first time you understand none of them; the
second you understand exactly the one that is happening to you.

---

## Appendix · The 21 silent traps

#### *The four from the assertions*

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The log says **PASS** and the properties did not run | `--assert` is missing at compile time | the `cover property` at 0 is the only one that warns you | Assertions |
| The property **always passes** | the antecedent never occurs, or the implication is the one that is wrong | one `cover property` per `assert property` | Assertions |
| **145 false positives** and the DUT is healthy | you sample it with the edge it is written on | stimulus on `negedge`, response of the DUT on `posedge` | Assertions · d7 |
| False positives **at the start** of every test | the `disable iff (!reset_n)` is missing | `default disable iff`, once, at the very top | Assertions |

- The four are of the same family as the ones above, with one aggravating factor:
  a broken assertion **looks exactly the same** as one that works. There is no output
  to look at

Note:
These four reached the appendix with the assertions and they are the only ones on the list
where the check itself is what fails — the rest are bugs of the
testbench; these are bugs of the one checking the testbench. That is why the antidote is
always the same and that is why it is worth repeating it until you are sick of it: **one `cover
property` per `assert property`**.
The first row is the cheapest to commit in this flow and it is worth showing it
live: taking `--assert` out of the `run.sh` of `code/u8/assertions` leaves the run with `+BUG=1`
at 0 `UVM_ERROR`. The 154 failures disappear without anything warning you.
The third is the lesson of the section and the only one on the list that is not in
any tutorial. The wrong reflex, when the false positives show up, is to
loosen the property until it shuts up: there you are left without a check and with the
feeling of having fixed it. The right reflex is to ask on which edge
the one driving the stimulus writes.

---

## Appendix · The 21 silent traps

#### *And the one the clocking block brings*

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The scoreboard fails **once every twenty** and the waveform looks fine | half the signals get read through `cb.sig` and the other half through `sig` | if it went into the clocking block, **the whole** protocol reads it through there | Interfaces and BFM |

- It is the only one on the list that **a tool adds**: without a clocking
  block it does not exist. Badly used it is worse than not using it
- Two names for the same wire, and they differ by one cycle:
  `code/u2/clocking/mezcla.sv` prints `3` and `4` at the same instant
- The variant of the same mistake: waiting for `@(posedge clk)` and then reading `cb.sig`.
  If you adopt the clocking block, you adopt **its event too**

Note:
This trap closes the appendix and it is the one that best sums up its thesis, because the
symptom is the worst of all the ones on the list: **intermittent**. The rest
fail always or never fail; this one fails when the data changes,
which is one run in however many and precisely the one you are not watching.
And it has a twist worth marking out loud: it is the only one on the list that
shows up *because* you used the tool that avoids another problem. The clocking
block takes the sampling race out and puts the possibility of this mixture in. It is not an
argument for not using it — it is the argument for using it **whole**, or not using it.
The rule in one line, which is Dave Rich's: if a signal belongs to the
timing contract of a clocking block, it is always accessed through that contract. The
long material is in `docs/clocking-blocks.md`.
