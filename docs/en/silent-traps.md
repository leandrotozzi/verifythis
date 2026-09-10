<!-- Generado por tools/build.mjs desde slides/en/172-apendice-trampas.md.
     NO editar a mano: la fila se corrige en la slide y esto se regenera con
     `npm run build`. `npm run check` falla si quedo viejo. -->

# The 21 silent traps of UVM

Everything that **compiles, runs and lies**: the mistakes of a UVM testbench that
give no warning, do not leave the regression in red, and get discovered weeks later —
or do not get discovered at all.

It is the day 7 appendix of [*Verify This!*](https://leandrotozzi.github.io/verifythis/en/),
a UVM course that runs end to end on **Verilator**, with no EDA
licences. It is out here outside the deck because it is the page you look for at three in the
morning, and a slide cannot be googled.

> **In verification the expensive mistake is not the one that breaks, it is the one that lies.** A
> compilation error costs two minutes; a testbench that passes measuring the wrong
> thing costs a tape-out.

## It compiles, it runs, and it lies

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The coverage gives **0 %** | the `new()` or the `sample()` of the covergroup is missing | one `sample()` per transaction, in the subscriber | Functional coverage |
| The daughter runs the method of **the mother** | without `virtual`, SV resolves by the **type of the variable**, at compile time | `virtual` on every method somebody is going to extend | Polymorphism |
| The component reads **somebody else's config** | `get(null, "*", …)` gives back the first thing that matches | `get(this, "", …)`, and `+UVM_CONFIG_DB_TRACE` | Tests |
| The test passes with **the wrong stimulus** | the `set_type_override()` arrived **after** the `create()` of the env | the override first, always. `+TOPOLOGY` gives it away | The env |
| The register model goes **green** and the field was never tested | the access starts with `WO`: `bit_bash` skips it and `do_check` drops it from the mask | if the field is readable, `WC` or `W1C`. `WO*` only if it really is not | RAL · d8 |

## The one publishing and the one listening

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The subscriber counts **0** and the monitor prints 1000 | the `connect()` in the `connect_phase` is missing | cross-check it: against what the one that already worked says | Analysis ports · d4 |
| The monitor **never publishes**, and the scoreboard screams | `bfm.command_monitor_h = this` is missing in the `build_phase` | the `uvm_fatal` shows up in the class that is **not** to blame | Analysis ports |
| The copy **loses the fields of the mother** | a `do_copy()` that does not call `super.do_copy(rhs)` | every `do_copy()` calls the one above first | Hierarchies |
| Two different transactions **compare equal** | `super.do_compare()` called on a loose line and thrown away | chained with `&&`, never loose | Transactions |

## Stimulus, scope and objections

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The edge bins **never get filled** | `dist` with `:=`: the weight goes to **each** value of the range | measure the histogram **once**, with `:/` | Constrained random |
| The `randomize()` **does not run** with the asserts switched off | `assert(x.randomize())` — `assert` is a simulation directive | `if (!x.randomize()) uvm_fatal(…)` | Constrained random |
| Under the override, **some** transactions are of the old type | a `new()` where a `type_id::create()` belonged | what goes through the factory is what gets created with `create()` | Transactions |
| **Both agents** start up the same | two `set()` with scope `"*"`: the second overwrites the first | the scope is the **path** of the one that reads, with `*` at the end | Agents · d6 |
| The agent starts up **active** even though you set `is_active` in the `config_db` | the missing `super.build_phase()`: the one that reads it is `uvm_agent` | either a config object, or `super` — never half of each | Agents |
| The simulation **never ends** | an `item_done()` that was not called | `+UVM_TIMEOUT=5000000,NO` first, the trace after | Agents |
| It ends at **t=0** and says PASS | nobody raised the objection around the sequence | `+UVM_OBJECTION_TRACE` | Sequences |

## The four from the assertions

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The log says **PASS** and the properties did not run | `--assert` is missing at compile time | the `cover property` at 0 is the only one that warns you | Assertions |
| The property **always passes** | the antecedent never occurs, or the implication is the one that is wrong | one `cover property` per `assert property` | Assertions |
| **145 false positives** and the DUT is healthy | you sample it with the edge it is written on | stimulus on `negedge`, response of the DUT on `posedge` | Assertions · d7 |
| False positives **at the start** of every test | the `disable iff (!reset_n)` is missing | `default disable iff`, once, at the very top | Assertions |

## And the one the clocking block brings

| The symptom | The cause | How to head it off | Section |
| --- | --- | --- | :-- |
| The scoreboard fails **once every twenty** and the waveform looks fine | half the signals get read through `cb.sig` and the other half through `sig` | if it went into the clocking block, **the whole** protocol reads it through there | Interfaces and BFM |

---

## The seven debug knobs

Which one to look at according to the symptom is in the other appendix of the course, *The debug
toolbox*: it is read in
[`en/libro/day7.html`](https://leandrotozzi.github.io/verifythis/en/libro/day7.html#which-one-to-use-according-to-the-symptom).

| Flag | What for |
| --- | --- |
| `+UVM_VERBOSITY=UVM_HIGH` | switch on the debug messages that are already written |
| `+UVM_CONFIG_DB_TRACE` | who put and who read every entry of the `config_db` |
| `+UVM_OBJECTION_TRACE` | who raised and who dropped every objection |
| `+UVM_TIMEOUT=5000000,NO` | cut off a hung simulation and see where it got stuck |
| `print_topology()` | the component tree UVM **actually** built |
| `--assert` | without this flag the concurrent properties do not get evaluated |
| `--trace` + GTKWave | when none of the six above is enough |

---

The course is **CC BY 4.0**. Code, examples and the capstone:
**[github.com/leandrotozzi/verifythis](https://github.com/leandrotozzi/verifythis)**
