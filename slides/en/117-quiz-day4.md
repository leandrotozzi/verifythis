<!-- es-sha: 5bc8cd355b58 -->
<!-- .slide: class="quiz" -->

## Review · Day 4

#### *1 of 5 · Observer Pattern*

**In the Observer pattern, what does the observed object know about its observers?**

- [ ] How many there are and of what type
- [ ] Only the first one that subscribed
- [ ] It knows them because they get handed to it in the constructor
- [x] Nothing: not how many there are, not who they are, not what they do with the data

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

> **With a `uvm_tlm_analysis_fifo`** — a `uvm_subscriber` has a single `write()`, so it can only listen to one port. The FIFO gives an `analysis_export` on one side and a `try_get()` on the other. It is what the VTALU scoreboard does.

---

<!-- .slide: class="quiz" -->

## Review · Day 4

#### *3 of 5 · Intra vs. inter thread*

**When the monitor publishes and the `write()`s of the subscribers run, how many threads are involved?**

- [ ] One per subscriber
- [ ] Two: the publisher's and the subscriber's
- [x] Only one: it is **intra**-thread communication, they are function calls
- [ ] It depends on how many subscribers there are

> **Only one** — `write()` is a `function`, not a `task`: it consumes no time and runs in the thread of the one publishing. That is precisely why **another** mechanism (put/get + FIFO) is needed to talk between threads.

---

<!-- .slide: class="quiz" -->

## Review · Day 4

#### *4 of 5 · Put and get ports*

**The consumer calls `get()` and the `uvm_tlm_fifo` is empty. What happens?**

- [x] It blocks until the producer puts a piece of data in
- [ ] It returns 0 and carries on
- [ ] A UVM fatal error
- [ ] It returns the last piece of data read

> **It blocks** — `get()` is blocking, and that is why it is declared `task` and not `function`. That is the whole synchronization: no hand-written signal handshake is needed.

---

<!-- .slide: class="quiz" -->

## Review · Day 4

#### *5 of 5 · try_get()*

**And `try_get()` with the FIFO empty?**

- [ ] It blocks just like `get()`
- [ ] It returns 1 with a garbage value
- [x] It returns 0 immediately, without blocking
- [ ] It waits one clock cycle and tries again

> **It returns 0 and carries on** — it is the non-blocking version, and that is why it can be a `function`. Notice that the scoreboard uses it in a `do ... while` to skip over the `no_op`s and the `rst_op`s.
