<!-- es-sha: 27c7476ffa1d -->
## When somebody has to wait

#### *You were already doing this, with modules*

- The name is scary and you have been using the mechanism forever: two modules
  with ports, each one with its `always`, passing data to each other

{{code:code/u5/threads/01-modulos/modules.sv#producer-and-consumer}}

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
`new("name", this)`. It is not a data field: it takes a parent, and that is why it
shows up in `print_topology()`. But it is not a `uvm_component` either —
`uvm_put_port` extends `uvm_port_base #(IF)`, and what hangs off the tree is an
internal `uvm_port_component` the port builds for itself
(`uvm_port_base.svh:137`). The FIFO on the next slide really is a component.
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
the FIFO in the `connect_phase` instead of the `build_phase`. UVM catches it with
an `ILLCRT` fatal —*"It is illegal to create a component ('x' under 'y') after the
build phase has ended"* (`uvm_component.svh:1721`)—, and at least it warns you with
the name. Forgetting the `connect()` of a `put`/`get` port **also** warns, and
well: `resolve_bindings()` reports a `UVM_ERROR [Connection Error] connection count
of 0 does not meet required minimum of 1` with the name of the port, in
`end_of_elaboration` and before a single cycle runs (`uvm_port_base.svh:886`).
The one that stays quiet is the **analysis port**, because its minimum is 0: a
`write()` into an unconnected port is legal and prints nothing. It is the same
asymmetry as the previous section, and it is the one to remember.
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

![try_get() returns 0 when the FIFO is empty](res/diagrams/en/threads_nonblocking.svg)
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

![Put port, TLM FIFO and get port between two threads](res/diagrams/en/threads_fig124.svg)
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

#### *`fork`: the three ways of starting in parallel*

```systemverilog
fork  esperar_done();  contar_ciclos();  join        // goes on when BOTH have finished
fork  esperar_done();  contar_ciclos();  join_any    // goes on with THE FIRST; the other stays alive
fork  esperar_done();  contar_ciclos();  join_none   // goes on NOW; both stay running
```

| Variant | The parent goes on… | What it is used for |
| --- | --- | --- |
| `join` | when **all** of them finish | two checks that both have to close |
| `join_any` | when **the first** one finishes | response against a timeout |
| `join_none` | **right away** | launching threads that live for the whole test |

- The difference between the three is not how they start —all three start everything at
  once— but **when the one that started them goes on**
- You have used `join_none` already: it is the `fork` of the day 2 `testbench` class, and it is
  what UVM does on its own with one `run_phase()` per component
- The branch left alive after a `join_any` **does not die on its own**. It goes on
  until it finishes — or until somebody kills it, which is the next slide

Note:
It is the unit called *threads* and up to here the threads were put there by UVM. This
slide and the next two are the three words of the language any production monitor
or driver is written with, and the three fit in one table.
The point worth repeating, because it is where everybody gets confused the
first time: **all three start the same**. The `fork` processes are all launched
at the same instant in the three variants. The only thing that changes is what the
parent process does immediately afterwards, and that is why the middle column is the one
to read.
One example per variant is enough to make it stick. `join`: send the stimulus and
count the cycles, and do not go on until both have finished. `join_any`: wait for the
DUT's response **or** for a timeout to expire, whichever happens first. `join_none`:
the monitor's `run_phase`, which starts and stays watching forever while
the rest of the testbench goes on.
And the hook back to day 2, worth making explicit: the hand-written `testbench`
class used `fork ... join_none` to start the three objects. It was not
a coincidence nor a trick — it is exactly what UVM does when it runs the
`run_phase` of a hundred components at once.


---

## When somebody has to wait

#### *`disable fork` and `wait fork`: turning off what stayed on*

```systemverilog
// The response-against-timeout idiom. The outer fork ISOLATES
fork begin
   fork
      begin  esperar_done();          `uvm_info("BFM", "it arrived", UVM_LOW)  end
      begin  repeat (100) @(posedge clk);  `uvm_error("BFM", "timeout")        end
   join_any
   disable fork;      // kills the sister that lost, and nobody else
end join

wait fork;            // kills nobody: it waits for ALL the children of this thread
```

- `disable fork` kills **every child process of the thread that executes it**. That
  is why the outer `fork begin ... end join`: without it, it also takes down
  whatever was already running
- `wait fork` is the opposite: it kills nothing, it **waits** for the children to finish.
  It is what a test uses so as not to close with transactions in flight
- The `join_any` + `disable fork` pair is the timeout of every production BFM. It gets
  written once and copied forever
- Measured: with the `disable fork`, the 5-unit branch that was going to print
  *"the response arrived"* **prints nothing** — the timeout of 3 killed it

Note:
The `disable fork` without the isolating `fork ... join` is the classic bug of this
construct and is worth drawing: it kills **every** child of the current thread, not
those of the `fork` next door. If the `run_phase` had already launched a monitor with
`join_none` and then does a bare `disable fork`, the monitor dies and the
testbench goes on running blind. There is no error, there is no warning: there is a log that
stops having lines.
The way to remember it is to think about the scope: `disable fork` does not say *which*
fork. It says "the children of this process". The outer `fork begin ... end join`
creates a new process whose only children are the two of the `join_any`, and that is why the
`disable` cannot reach any further.
`wait fork` is the quiet partner and gets used far less than it should: it is
what is needed at the end of a sequence or of a `run_phase` that launched things
with `join_none` and does not want the phase to end with half the stimulus in the
air. In UVM the same problem is solved with objections — but inside a
task, `wait fork` is the answer.


---

## When somebody has to wait

#### *⚠ The trap: the `for` index inside the `fork`*

```systemverilog
int i;                                  // declared OUTSIDE the for: there is only one
for (i = 0; i < 3; i++)
   fork  $display("i = %0d", i);  join_none      //  i = 3   i = 3   i = 3

for (int j = 0; j < 3; j++)             // declared IN the for: one per pass
   fork  $display("j = %0d", j);  join_none      //  j = 0   j = 1   j = 2

for (i = 0; i < 3; i++)
   fork  begin
      automatic int k = i;              // the copy is made WHEN the thread starts
      $display("k = %0d", k);
   end join_none                                 //  k = 0   k = 1   k = 2
```

- A `join_none` **does not execute anything yet**: it leaves the thread ready and goes on. By
  the time the thread runs, the `for` has already finished and the variable holds the last value
- If the variable is declared **inside** the `for`, each pass has its own and there
  is no problem. It is what the LRM says and what Verilator does
- If it comes from outside —an `int` of the `run_phase`, a field of the class— it has to be
  **copied** with an `automatic` as the first line of the block
- Measured on Verilator 5.052: the three lines above print `3 3 3`,
  `0 1 2` and `0 1 2`

Note:
It is the most expensive threads bug and the hardest to see when reading the code,
because the three versions look very much alike. It is worth asking the question before
showing the answer: *"what does the first one print?"*. Almost everybody says
`0 1 2`.
The explanation to leave behind is a single sentence: **`join_none` does not run the
thread, it schedules it**. The `for` walks straight to the end, and only then does the
scheduler give the three threads their turn — and they read the variable *now*, not
when they were launched. With `i` outside there is a single variable, and now it holds 3.
The version with `for (int j …)` works and it is worth saying why, so it does not
look like magic: the LRM declares automatic the variable of a `for` that declares it,
so each pass has its own copy. It is measured here, it is not theory.
The case where the `automatic` is needed anyway is the one that shows up in real life:
the index is not the `for`'s, it is a field of the class or an argument of the task.
There is no copy per pass there and it has to be made by hand. The practical rule to
take home: **if a thread launched with `join_none` reads a variable from outside,
copy it into an `automatic` on its first line.**

---

## When somebody has to wait

#### *Summary of the unit*

- **Inter**-thread communication between objects is the equivalent of what ports
  do between modules: passing data from one thread to another
- UVM provides it with *uvm_put_port*, *uvm_get_port* and *uvm_tlm_fifo*
- Any object that wants to communicate with another thread has to instantiate a
  port and connect it to a FIFO
- Careful with the pair of names: the *analysis ports* of the two previous sections
  are **intra**-thread —`write()` is a `function` and runs in the thread of the
  one publishing—; this is **inter**-thread, and that is why `put()` and `get()`
  are `task`
- And underneath it all there is `fork`: `join` waits for all, `join_any` for the first,
  `join_none` for none. `disable fork` kills the children and `wait fork` waits for them
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
