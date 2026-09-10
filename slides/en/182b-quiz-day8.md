<!-- es-sha: b42e9a15dfcc -->
<!-- .slide: class="quiz" -->

## Review · Day 8

#### *1 of 8 · The access string*

**`CLR` clears itself when you write a 1 to it. You declare it `"WOC"`, and `bit_bash` and `mirror(UVM_CHECK)` give zero errors. What happened?**

- [ ] Nothing: `WOC` is the access that describes a field that clears on a write
- [ ] `WOC` is not in the LRM, so UVM treats it as a plain `RW`
- [x] Both skip `WO*` accesses: that bit never got tested
- [ ] The predictor leaves the mirror at `x`, and a comparison against `x` always passes

> **Green is not checked** — `uvm_reg_bit_bash_seq.svh:129-133` skips every field whose access starts with `WO` (*"you are not supposed to read them"*), and `do_check` takes it out of the comparison mask (`uvm_reg.svh:2782-2788`). The only trace is in the timing: bashing `CTRL` takes four transfers less. The right access is `WC` (or `W1C`), and with it the bit does get bashed. A `WO*` access is the cheapest way there is of switching a check off without noticing.

---

<!-- .slide: class="quiz" -->

## Review · Day 8

#### *2 of 8 · Automatic or explicit prediction*

**What changes between `set_auto_predict(1)` and hooking a `uvm_reg_predictor` to the monitor?**

- [x] With auto-predict the model believes what it **meant** to send, not what happened
- [ ] Nothing: the predictor is the internal implementation of auto-predict
- [ ] The predictor is faster: it does not build the bus transaction
- [ ] Auto-predict only works frontdoor, and the predictor works backdoor too

> **The one who checks cannot believe the one who drives** — with `set_auto_predict(1)`, `model.CTRL.write()` updates the mirror at the moment of the call, before the bus has done anything: if the driver sends the transfer wrong, the model stays convinced. With the predictor, the mirror only changes once the monitor has seen the wire. It is the same drawing as the capstone scoreboard, with a library piece instead of a hand-written class. And it is free: the monitor and its analysis port **were already there**.

---

<!-- .slide: class="quiz" -->

## Review · Day 8

#### *3 of 8 · volatile*

**`STATUS` changes on its own, without anybody writing it. What are you saying when you declare it `volatile` in `configure()`?**

- [x] That the mirror is not evidence: the value can change without going through the bus
- [ ] That UVM is going to re-read it from the DUT before every comparison, to be safe
- [ ] That the field drops out of the map and stops having an address
- [ ] That it has to be read backdoor, because the frontdoor does not get there in time

> **The mirror stops being evidence** — a model predicts *"what I wrote is what I am going to read"*, and for a `volatile` field that sentence is false. The two `UVM_WARNING GET_MIRRORED_VAL/VOL` of the example are the library saying exactly that, and they are in the output on purpose. What does have to be checked gets checked where it is known: in the **scoreboard**, and in the model goes `set_compare(UVM_NO_CHECK)` on that field so that RAL does not invent an error.

---

<!-- .slide: class="quiz" -->

## Review · Day 8

#### *4 of 8 · mirror() against read()*

**`model.CTRL.read(status, data)` and `model.CTRL.mirror(status, UVM_CHECK)`. How do they differ?**

- [ ] `read` goes over the bus and `mirror` stays in the mirror, with no transfer at all
- [ ] `mirror` writes the mirror into the DUT, to leave the two of them equal
- [ ] `read` updates the mirror and `mirror` does not touch it, so as not to hide an error
- [x] Both read from the DUT; `mirror` also compares against what the model believed

> **`mirror` is a register scoreboard in one word** — both read from the DUT; the difference is that `mirror` compares against what the model believed **before** the read, and if it does not match it reports a `uvm_error` without anybody writing a check. And a read *is* a prediction: both update the mirror afterwards.

---

<!-- .slide: class="quiz" -->

## Review · Day 8

#### *5 of 8 · Who knows about the bus*

**What does the `uvm_reg_block` know about the APB?**

- [ ] The base address and the width of `PADDR`, which reach it through the `uvm_reg_map`
- [x] Nothing: the only one that knows about the bus is the adapter
- [ ] Everything: that is why there is one register model per protocol
- [ ] The SETUP and ACCESS timing, to predict the wait state of the read

> **The model does not know there is an APB underneath** — swap the adapter and the same model drives an AHB. The adapter is twenty lines, once per protocol, and it is the file that comes with a VIP you bought. Watch out for one thing: `bus2reg` is called **by the predictor too**, with the item the monitor saw, so an adapter that depends on something the driver put there works in one direction and fails in the other.

---

<!-- .slide: class="quiz" -->

## Review · Day 8

#### *6 of 8 · DPI and time*

**Can an `import "DPI-C" function` of the golden model wait for a clock edge?**

- [ ] Yes, by putting a `#1` inside the `.c`
- [x] No: a `function` runs in zero time
- [ ] Yes, as long as the `.c` is compiled with Verilator's timing support
- [ ] Yes: the simulator suspends the C thread for the duration of the call

> **Zero time, like any `function`** — to consume time you need `import "DPI-C" task`, and with a clarification almost every tutorial skips: C cannot block by itself. A DPI task consumes time **only** if it is declared `context` and from the C it calls back into an `export "DPI-C" task` of SystemVerilog, which is the one that waits for the edge. And at that point it is no longer a golden model, it is a bus model.

---

<!-- .slide: class="quiz" -->

## Review · Day 8

#### *7 of 8 · undefined reference*

**The `.c` is written and it compiles, and the link fails with *undefined reference* to the golden model function. What do you look at first?**

- [ ] Whether the DPI flag is missing from the `verilator` command line
- [ ] Whether the `.c` is in its own `-f` and not mixed in with the `.sv`
- [x] The name, and the `extern "C"`: the symbol may have come out mangled
- [ ] Whether the SystemVerilog `function` is declared `virtual` so the symbol gets exported

> **The compiler does not cross the two declarations: the one that joins them is the linker** — hence an error about something that is written, right there, in plain sight. It is almost always one of two things: the name does not match letter for letter, or the file got compiled as C++ and the symbol came out mangled. That last one is literally the case here: Verilator hands the user's sources to the C++ compiler, so the `.c` needs its `extern "C"`. And there is no DPI flag: the `.c` goes on the `verilator` command line like any other source.

---

<!-- .slide: class="quiz" -->

## Review · Day 8

#### *8 of 8 · The scoreboard that never shouted*

**The scoreboard with the golden model in C runs a thousand operations and reports not one. Is that enough?**

- [ ] Yes: a thousand comparisons without a single difference is the definition of verified
- [ ] Yes, as long as the functional coverage closed at 100 % on top of that
- [ ] No, because both sides share the opcode `enum` and cancel each other out
- [x] No: a scoreboard that has never seen an error is not tested

> **The model has to be broken on purpose** — `vtalu_golden_bug(1)` mutates the multiplication and `run.sh` demands that the scoreboard shout. If it does not shout, the testbench is comparing against itself and nobody was going to find out: it is the same mutation test the capstone grader does with `+BUG=1`, from the other side of the wire. And the duplicated `enum` is real but it is a different symptom: if **every** comparison fails at once, it is the mapping; if one in six fails, it is the DUT.
