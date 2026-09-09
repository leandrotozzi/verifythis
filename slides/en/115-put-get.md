<!-- es-sha: 3415a20700e5 -->
## Who waits for whom

#### *What to send and how to send it*

- The analysis ports split the analysis: the monitor watches, the subscribers
  interpret. The same is still missing on the stimulus side
- Today the `base_tester` does **two** things: it picks the operation *and* it
  applies it on the BFM cycle by cycle. They are two jobs that change for
  different reasons
- The **what** changes with every test. The **how** changes only if the protocol
  of the DUT changes — which means, almost never
- Separating them leaves the protocol written in a single place: the **driver**.
  Every new test writes what to send and never looks at an `@(negedge clk)` again
- And since the two run in different threads, the joint is the one from
  inter-thread communication: `uvm_put_port`, `uvm_get_port` and a
  `uvm_tlm_fifo` in the middle

Note:
It is the third time the course does the same operation, and it is worth saying
it that explicitly because it is what has to be taken home: in interfaces and BFM
we took the protocol out of the test and put it in the BFM; in the analysis ports
we took the observing out of the analysers and put it in the monitor; here we
take the applying of the stimulus out of the generator and put it in the driver.
The question that orders everything: does this change when the test changes, or
when the design changes? If it changes with the test, it is stimulus. If it
changes with the design, it is structure. They do not go in the same class.
And the notice of where this is heading: in the agents this put/get pair is
called a sequencer and comes already in place, and the tester is called a
sequence. What we are assembling by hand here is exactly what UVM gives you
ready-made — that is why it gets assembled by hand first.

---

## Who waits for whom

#### *The tester does two jobs, and one of them is not its own*

- This is how the `base_tester` of the analysis ports was left, and it does
  **two** jobs:
  - it picks which operation to send
  - and it applies it on the BFM, cycle by cycle
- The second one is the one that should not be there: it is protocol, and the
  protocol does not change when the test changes
- The class that takes that job away is called a **driver**: it takes a piece of
  data from the testbench and turns it into signals

{{code:code/u5/analysis-ports/tb_classes/base_tester.svh|lines=14-29}}

Note:
It is worth reading the code pointing a finger at where one job ends and the
other starts: `get_op()` and `get_data()` are the **what**; everything that
follows —the `bfm.send_op()`, the wait, the cycle— is the **how**. They are glued
together in the same task and that is why they cannot be changed separately.
The proof that they are wrongly together is a question: if tomorrow the DUT adds
a signal to the protocol, how many classes have to be touched? Every one that
inherits from `base_tester`, even though none of them knows anything about
protocol. That is coupling, and the classic symptom is exactly this one — a class
that changes for two different reasons.
The name **driver** is worth saying already, even though the class does not exist
yet, so that the word does not show up for the first time on day 6. A driver is
what turns a piece of data into signals. Nothing more than that, and that is why
it is the only class of the testbench that has the right to write an
`@(negedge clk)`.

---

## Who waits for whom

#### *How it ends up split*

- The result: one class decides **what** to send and another one knows **how** to
  send it, and between the two there is a FIFO instead of a method call

![The tester picks the stimulus and the driver applies it](res/diagrams/put-get_fig125.svg)
<!-- .element: class="grande" -->

Note:
The box in the middle is the one to point at, because it is the one that
surprises: between the tester and the driver **there is no arrow**. There is a
FIFO. The tester does not call the driver, and it does not even have a handle to
it.
It is worth making the comparison with the diagram of the analysis ports, which
is two sections back: over there the monitor did not know its listeners either.
It is the same idea applied on the other side of the testbench, and it is the
reason why on day 6 every sequence can be changed without touching the driver.
And the difference between the two diagrams that does matter, because it is
question 3 of the review: that one was **intra**-thread —`write()` is a function
and does not wait for anybody—, this one is **inter**-thread. Here the one
putting can be left waiting, and that is precisely the synchronization that used
to have to be written by hand.

---

## Who waits for whom

#### *The `env`: seven objects and five `connect()`*

- Mantra: "Ports connect to exports"

{{code:code/u5/put-get/tb_classes/env.svh|lines=14-34}}

Note:
Count the objects of this `build_phase`: there are **seven**, plus five
`connect()`. That number is the one to remember, because in the agents this same
testbench is going to have one agent and two subscribers. Worth writing it on the
board so you can come back to it.
The two new lines of the `connect_phase` are a pair and get read together: the
tester puts into the `put_export` of the FIFO, the driver takes out of the
`get_export`. Nobody connects the tester to the driver — **they do not know each
other**, and that is the point.
The mantra has a reason worth giving instead of repeating it like a parrot: the
*port* is the one that asks for the service, the *export* is the one that offers
it. The FIFO offers both ends, so it has two exports. If you write it the other
way round it does not compile, and the compiler message is one of the worst in
UVM.
And the detail that gets forgotten: `command_f = new(...)`, not `create()`.
FIFOs are not in the factory.

---

## Who waits for whom

#### *The `base_tester`, without a single signal*

- Only one thing changes: where there was a handle to the BFM there is now a
  `uvm_put_port #(command_s)` called `command_port`
- `random_tester` and `add_tester` **do not get touched**. They only define
  `get_op()` and `get_data()`, and neither of the two knew how the stimulus was
  applied
- That is the return on having separated things properly in the env: the change
  stopped at the base class

{{code:code/u5/put-get/tb_classes/base_tester.svh|lines=5-38}}

Note:
What matters about this class is what **disappeared**: there is not a single
`@(negedge clk)`, nor a `bfm.start`, nor the wait for the `done`. The tester was
reduced to picking what to send and putting it on the port.
And yet `random_tester` and `add_tester` **were not touched**: they only define
`get_op()` and `get_data()`, and neither of the two knew how the stimulus was
applied. That is what separating properly buys you — the change stopped at the
base class.
The `put()` is a `task` and it blocks: if the driver is still handling the
previous operation, the tester waits there. The one-element FIFO of inter-thread
communication is what synchronizes the two threads, without a single semaphore.
And there is a `#500` at the end, before the `drop_objection`, worth pointing out
as what it is: a patch. It is there so that the objection does not drop while the
last operation is still travelling. In the sequences it disappears, because
`finish_item()` only comes back when the operation has really finished. An
eyeballed `#500` in a testbench is always an unanswered question.

---

## Who waits for whom

#### *The driver: the only one that touches the wire*

- A `forever` with two lines: `get()` a command —which blocks until there is one—
  and apply it with `send_op()`. The whole protocol lives here

{{code:code/u5/put-get/tb_classes/driver.svh|lines=1-22}}

Note:
This division is the one UVM formalizes in the agents: the tester decides WHAT to
send, the driver knows HOW to send it.
In a real agent the tester is going to be called a sequence and this put/get is
going to be called get_next_item / item_done. Anticipating it here makes day 6
start downhill.

---

## Who waits for whom

#### *Summary of the unit*

- The testbench ended up split into three layers that change for different
  reasons: the **stimulus** (tester), the **protocol** (driver and monitors) and
  the **analysis** (scoreboard and coverage)
- None of them knows the insides of the others: between them only commands and
  results travel
- What is still missing is for the testbench to know how to **tell what is going
  on**, which is the unit that follows

Note:
It is worth closing the day with the three layers written on the board, because
it is the map that orders everything that comes: stimulus, protocol, analysis.
The four sections of today were about building that separation, and tomorrow's do
not add layers — they put UVM names on the ones already there.
The control question, which besides answers itself if the day closed properly: in
which of the three layers does an `@(negedge clk)` live? In one only, the
protocol. If it shows up in another one, something got separated wrong.
And the notice about what is missing, worth giving now: between the tester and
the driver travel `command_s`, which are structs. They work, but they do not
randomize themselves, they do not compare themselves and they do not print
themselves — and that is exactly what day 5 is going to fix by turning them into
transactions.
