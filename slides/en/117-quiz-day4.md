<!-- es-sha: 70efaa5453b3 -->
<!-- .slide: class="quiz" -->

## Review · Day 4

#### *1 of 5 · Observer Pattern*

**In the Observer pattern, what does the observed object know about its observers?**

- [ ] How many there are and of what type
- [ ] Only the first one that subscribed
- [ ] It knows them because they get handed to it in the constructor, one by one
- [x] Nothing: not how many there are, not who they are

> **It knows nothing** — and that ignorance is the whole point. Adding a fourth subscriber does not force you to touch one line of the one publishing.

---

<!-- .slide: class="quiz" -->

## Review · Day 4

#### *2 of 5 · Analysis Ports*

**A `uvm_subscriber` needs data from two different analysis ports. How does that get solved?**

- [ ] By implementing the `write()` method twice
- [x] With a `uvm_tlm_analysis_fifo` for the second port
- [ ] By registering the component twice in the factory, once per port
- [ ] By connecting both ports to the same `analysis_export`

> **With a `uvm_tlm_analysis_fifo`** — a `uvm_subscriber` has a single `write()`, so it can only listen to one port. The FIFO gives an `analysis_export` on one side and a `try_get()` on the other. It is what the VTALU scoreboard does. The other way is `` `uvm_analysis_imp_decl ``, which manufactures one `write_` per suffix: they are not two `write()` in the same class, which SystemVerilog does not allow.

---

<!-- .slide: class="quiz" -->

## Review · Day 4

#### *3 of 5 · Intra vs. inter thread*

**When the monitor publishes and the `write()`s of the subscribers run, how many threads are involved?**

- [ ] One per subscriber
- [ ] Two: the publisher's and the subscriber's
- [x] Only one: `write()` is a function call
- [ ] One per subscriber plus the monitor's, and UVM syncs them at the end of the delta

> **Only one, and it is intra-thread communication** — `write()` is a `function`, not a `task`: it consumes no time and runs in the thread of the one publishing. That is precisely why **another** mechanism (put/get + FIFO) is needed to talk between threads.

---

<!-- .slide: class="quiz" -->

## Review · Day 4

#### *4 of 5 · Put and get ports*

**The consumer calls `get()` and the `uvm_tlm_fifo` is empty. What happens?**

- [x] It blocks until the producer puts a piece of data in
- [ ] It returns 0 and carries on
- [ ] A UVM fatal error
- [ ] It returns the last piece of data read, which stays in the FIFO until overwritten

> **It blocks** — `get()` is blocking, and that is why it is declared `task` and not `function`. That is the whole synchronization: no hand-written signal handshake is needed.

---

<!-- .slide: class="quiz" -->

## Review · Day 4

#### *5 of 5 · try_get()*

**And `try_get()` with the FIFO empty?**

- [ ] It blocks just like `get()`
- [ ] It returns 1 with a garbage value
- [ ] It waits one clock cycle and tries again, up to the timeout of the phase
- [x] It returns 0 immediately, without blocking

> **It returns 0 and carries on** — it is the non-blocking version, and that is why it can be a `function`. Notice that the scoreboard uses it in a `do ... while` to skip over the `no_op`s and the `rst_op`s.
