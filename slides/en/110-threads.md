<!-- es-sha: 1bf3e9e096ff -->
## When somebody has to wait

#### *You were already doing this, with modules*

- The name is scary and you have been using the mechanism forever: two modules
  with ports, each one with its `always`, passing data to each other

{{code:code/u5/threads/01-modulos/modules.sv|lines=6-33}}

- That **is** communication between threads. The only thing missing is doing it
  between objects, which have no ports

Note:
The slide exists to defuse the fright before the word TLM shows up. It is worth
pointing at the code and saying it that bluntly: here are two processes running
at the same time and passing data to each other over a wire, and nobody called
that "inter-thread communication" in twenty years of Verilog. It is the same
thing.
The only thing that changes in the rest of the section is **where each process
lives**: instead of two `always` in two modules, two `run_phase()` in two
objects. And since an object has no port list, the wire has to be replaced by
something.
The question to leave hanging, which is exactly the one on the next slide: what
does the wire get replaced with? The answers that are going to come out —a shared
variable, a semaphore, a mailbox— are all correct, and that is precisely the
problem UVM comes to solve.

---

## When somebody has to wait

#### *An object has no port list*

- What SystemVerilog does have is shared handles, semaphores and mailboxes
- That is enough to solve it, and that is the problem: **everybody solves it
  differently**, and afterwards nobody can read the testbench of the person next
  to them
- UVM standardizes a single way, in two pieces:
  - *Ports*: they get instantiated in a `uvm_component` so that its `run_phase()`
    can talk to another thread. *Put port* to send, *get port* to receive
  - *TLM FIFO*: the object that joins a put port to a get port. `new()` creates it
    with **size 1** by default —`new(name, parent, size = 1)`—, and with `0` it
    would be unbounded. The one in the example uses the default
- With size 1 the FIFO is not a buffer, it is a **meeting point**: the one putting
  waits for the other one to take out

Note:
What has to be taken away from the slide is that size 1 is not a limitation of
the class: it is the default argument of the constructor. With
`new("f", this, 0)` the FIFO is unbounded, and there the one putting never
blocks.
Size 1 is the one that synchronizes: it blocks the producer until the consumer
takes out, and that replaces the semaphore and the flag everybody used to write
by hand. It is the same `start`/`done` handshake of the BFM, but between objects.

---

## When somebody has to wait

#### *The producer as an object*

- The producer declares a `uvm_put_port` and calls `put()`. That is all: no signal
  handshake, no shared flag, no semaphore

{{code:code/u5/threads/02-bloqueante/producer.svh}}

Note:
What has to be pointed out is what is **not** in this class: there is no
`@(posedge something)`, there is no `wait`, there is no variable saying "ready".
The producer puts and carries on; if the other one has not taken it out yet, the
`put()` stops it on its own.
The detail of form, which is the one that gets copied wrong: the port gets
**instantiated** in the `build_phase` like any other component, with
`new("name", this)`. A port is a `uvm_component`, not a data field — that is why
it takes a parent, and that is why it shows up in `print_topology()`.
And the parameter: `uvm_put_port #(T)`. That `T` has to be the same in the port,
in the get port and in the FIFO. If they do not match it does not compile, which
is the good news —it is one of the few UVM connection errors you see at compile
time and not at three in the morning—.

---

## When somebody has to wait

#### *The consumer as an object*

- On the other side, `uvm_get_port` and a `get()`. With the FIFO empty, `get()`
  **blocks** and the thread stays there
- When the producer puts a piece of data in, the `get()` unblocks and carries on
  with the data already read. Nobody wrote the synchronization: the FIFO gives it

{{code:code/u5/threads/02-bloqueante/consumer.svh}}

Note:
`get()` is a **task**, and that word is the whole section. A `function` cannot
have an `@` or a `#`, so it cannot wait for anybody; a `task` can. If somebody
wonders why the analysis ports of the previous section did not block, the answer
is right there: `write()` is a `function`.
The argument by reference is also worth naming: `get(t)` does not return the
data, it **writes** it into the variable you hand it. It is the TLM convention
and it surprises you the first time, because you expect a `t = get()`.
And the practical warning: a `get()` on a FIFO that never fills up is a thread
hung forever. There is no error and no warning — the simulation ends when the
objection drops and that consumer simply never ran. It is a sibling of the
forgotten `item_done()` of day 6.

---

## When somebody has to wait

#### *Instantiating the three: two components and a FIFO*

- The `uvm_tlm_fifo` takes **the same parameter** as the two ports: if they do not
  match, it does not compile
- The three get instantiated in the `build_phase` of the test, like any component.
  The FIFO is a `uvm_component` too
- And the order is the usual one: UVM calls every `build_phase` from the top down,
  and only once it has finished does it start the `connect_phase` from the bottom
  up

{{code:code/u5/threads/02-bloqueante/communication_test.svh}}

Note:
It is worth saying again why the order is that one, because here you see what it
is for: the `connect_phase` connects a port to an export, and for that both
objects have to exist. If `connect` were top-down, the test would try to connect
children that had not been built yet.
The classic error of this slide, which compiles and fails at run time: creating
the FIFO in the `connect_phase` instead of the `build_phase`. UVM throws a fatal
— `Cannot create a component during connect` — and at least it warns you. Worse
is forgetting the `connect()`: there the port is left unconnected and the fatal
shows up on the first `put()`, much later and without saying which port it was.
And one worth pointing out in passing: here the producer and the consumer are
children of the **test**, not of an env. It is on purpose, because the section is
about the mechanism. In the real testbench this goes inside the agent, with the
sequencer on one side and the driver on the other.

---

## When somebody has to wait

#### *Connecting them: `put_export` and `get_export`*

- It is the same `connect()` as the analysis ports: on one side the **port**, on
  the other the **export** the FIFO provides
- `uvm_tlm_fifo` exposes two: `put_export` for the one that puts and `get_export`
  for the one that takes out
- The rule that holds for all of TLM: **the port connects to the export**, never
  two ports to each other

{{code:code/u5/threads/02-bloqueante/connect_phase.sv}}

{{code:code/u5/threads/02-bloqueante/result.txt}}

Note:
Two things about the output, which do not belong to this section but are seen
here first.
The messages come out with `` `uvm_info ``, not with `$display`: that is why
every line brings the time, the hierarchical path of the component and the file
along on its own. That is free, and it is reporting, which they already saw
closing day 3.
And the other one: every `@` says 0. In this example there is not a single
`#delay` —the blocking handshake suspends and resumes within the same instant—,
so the synchronization of the two threads does not come from the clock: it comes
from the one-element FIFO. In the example that follows the clocks show up and the
numbers stop being 0.

---

## When somebody has to wait

#### *NON-blocking communication*

- Blocking is fine as long as the one waiting has nothing better to do. With a
  clock in the middle, standing there waiting means losing an edge
- That is what the non-blocking versions are for: `try_put()` and `try_get()`
- They return 1 if they could and **0 if they could not**, and carry on. That is
  why they are `function` and not `task`: they consume no time

{{code:code/u5/threads/03-no-bloqueante/consumer.svh}}

{{code:code/u5/threads/03-no-bloqueante/results.txt}}

Note:
try_get() returns 0 and carries on: it does not wait. It is the difference
between a consumer that hangs until there is data and one that can do something
else in the meantime. Careful, in `results.txt` the zeros are not visible —the
consumer only prints when it gets data—: they are in the timeline of the slide
that follows.
The time on each line is not printed by the message: UVM puts it in the `@`, and
that is why here you can read the race between the two clocks without having
written a single line of formatting.

---

## When somebody has to wait

#### *NON-blocking communication: the timeline*

![try_get() returns 0 when the FIFO is empty](res/diagrams/threads_nonblocking.svg)
<!-- .element: class="grande" -->

- The producer puts a piece of data in every 17 ns and the consumer looks every
  14 ns: the clocks run differently, and on two edges the FIFO is empty
- There `try_get()` returns 0 and the consumer carries on. With `get()` it stayed
  waiting

Note:
The numbers are not from a drawing: they are the `@` of the `Sent` and `Received`
of `results.txt`, the previous slide.
The edge to make them see is the one at 49 ns. Data 3 only gets put in at 51, so
the consumer arrives a little early, leaves empty-handed and comes back 14 ns
later. With `get()` that thread was left blocked right there, and in a testbench
with a clock that is a lost edge.

---

## When somebody has to wait

#### *How TLM diagrams are read*

![Put port, TLM FIFO and get port between two threads](res/diagrams/threads_fig124.svg)
<!-- .element: class="grande" -->

- The convention holds for all the UVM material you are going to read afterwards:
  - *Square:* put port / get port — the one that **starts** the call
  - *Circle:* export — the one that **receives** it and implements it
  - *Diamond:* analysis port — the one from the two previous sections

Note:
It is worth the student taking the convention home, because it is the same one in
the *UVM User Guide*, in the Verification Academy and in any testbench diagram
they get handed at work. It does not belong to this course.
The rule that orders the three figures, and the one that makes a TLM diagram
readable without a legend: **the square end always points at the circle**. The
one with the square is the one that calls; the one with the circle is the one
that has the method written. That is why a port connects to an export and never
to another port.
The diamond is the special case they have already seen: an analysis port can
point at many circles at once, and that is why it is drawn differently. The other
two are one to one.

---

## When somebody has to wait

#### *Summary of the unit*

- **Inter**-thread communication between objects is the equivalent of what ports
  do between modules: passing data from one thread to another
- UVM provides it with *uvm_put_port*, *uvm_get_port* and *uvm_tlm_fifo*
- Any object that wants to communicate with another thread has to instantiate a
  port and connect it to a FIFO
- Careful with the pair of names: the *analysis port* of the two previous sections
  are **intra**-thread —`write()` is a `function` and runs in the thread of the
  one publishing—; this is **inter**-thread, and that is why `put()` and `get()`
  are `task`
- Now we have to use this to wire our TB: we are going to separate the stimulus
  generation from the driver of the DUT

Note:
Worth closing with the two-column table that one producer, many listeners opened
with, because it is the one that orders the four units of the day:
Intra-thread — `uvm_analysis_port` + `uvm_subscriber`, `write()` is a `function`,
it consumes no time, a single thread, and it is for the *analysis layer*.
Inter-thread — `uvm_put_port` / `uvm_get_port` + `uvm_tlm_fifo`, `put()` and
`get()` are `task`, they block, two threads, and they are for handing stimulus to
a driver.
The short way of telling them apart, and it is question 3 of the review: **if it
is a `function`, it is intra-thread.** A function cannot have an `@` or a `#`, so
it cannot wait for anybody. The word `task` is the one that gives away that there
are two threads.
