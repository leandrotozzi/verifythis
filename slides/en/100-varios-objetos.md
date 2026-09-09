<!-- es-sha: 904b4827022b -->
## One producer, many listeners

#### *Two ways of talking between objects*

- The structural paradigm asks *which steps to follow*. OOP asks **what objects
  there are and how they talk to each other** — and that is where the
  single-`initial` testbench ends
- And talking, between objects, is exactly two things. The difference is whether
  the two run in **the same thread** or not
- **Same thread:** one calls the other's method and comes straight back. It is
  the `write()` of a `uvm_analysis_port` — the first two sections of the day
- **Different threads:** the two run at the same time and they have to be
  **coordinated**, which means somebody is going to have to wait. It is
  `put` / `get` and the TLM FIFOs — the last two
- The whole of day 4 is those two columns. We start with the left-hand one

Note:
This slide is the map of the day: the four sections that follow are the two
columns below, in order.
It is worth writing the two columns on the board and coming back to them every
time a new port shows up, because the question to ask yourself in front of any
UVM port is always the same: **can this block?** If it runs in my thread, no; if
it runs in another one, yes, and then it has to be a `task`.
That is also the criterion that orders the vocabulary of the day: `write()` is a
`function` —it consumes no time—, `put()` and `get()` are `task`. The signature
tells you which side of the divide you are on before you read a line of the
implementation.

---

## One producer, many listeners

#### *The one who publishes does not know who reads it*

- A piece of testbench data almost never has **one** addressee: every command the
  monitor sees is wanted by the scoreboard, the coverage and, tomorrow, the log
- The obvious solution is for the producer to keep a handle to every consumer and
  call their method. It works, and adding a consumer forces you to **touch the
  producer**
- It is the same problem the BFM solved in interfaces and BFM, one level up:
  there we hid the wire, here we want to hide **the list of addressees**
- The answer is an old pattern: the producer publishes on a port and does not
  know —nor care— who is on the other side
- The section builds it by hand with dice first, and only then replaces it with
  `uvm_analysis_port`. The example is deliberately foreign to hardware

Note:
The dice example is deliberate and it is worth defending if somebody asks why we
do not start with the VTALU: you see the pattern without the noise of the
protocol. When it shows up on the DUT in the analysis ports, the student is no
longer learning two things at once.
The question that orders the section: which is the only line that has to be
written to add a fourth observer? A `connect()`. None in the producer. That is
the criterion to look at every line of code from here on with.
And it is worth anticipating the limit, because it is inter-thread communication:
this is communication inside **a single thread**. `write()` is a `function`, it
consumes no time, and it runs in the thread of the one publishing. To talk
between threads something else is needed.

---

## One producer, many listeners

#### *The problem: two dice, three things to count*

- Write a program that simulates rolling two dice (2d6) 20 times and reports the following
  - The average of the values the dice gave
  - A histogram with the frequency of values
  - A coverage report that shows whether every possible value from 2 to 12 came up

![Two d6 and the histogram of their sums](res/funs/dados.svg)
<!-- .element: class="grande" -->

Note:
It is worth posing it as a programming problem before showing a single line: they
are three consumers of the same piece of data, and each one does something
different with it. Nobody thinks about hardware here, which is exactly the idea.
The three reports have something in common that is worth pointing out now: none
of them can be worked out from a single roll. The three accumulate and only
report at the end, and that is why the three are going to need two methods, not
one.
And a quick question for the classroom, one that gets collected later: if
tomorrow they ask for a fourth report —the most repeated roll, say—, which files
have to be touched?

---

## One producer, many listeners

#### *The three observers: the same shape, three bodies*

{{code:code/u5/varios-objetos/01-sin-analysis-port/average.svh}}

- `average` is the simplest one: a `write(int t)` that accumulates, and a
  `report_phase()` that divides and reports at the end
- That is the **shape** the three of them are going to have: they receive one
  roll at a time, and the result only exists once everything is over

Note:
It is worth showing the whole class only once —this one— and after that only the
`write()`s, because what matters is that the shape repeats.
Two details that get collected later: the `report_phase` runs **when the last
objection drops**, not at the end of the `run_phase`, and that is why the average
comes out complete. And `dice_total` and `count` are `protected`: the one
publishing cannot touch them, only call `write()`.
When this is the VTALU, in the analysis ports, `average` is going to be the
scoreboard and the `report_phase` the verdict of the run. Same shape.

---

## One producer, many listeners

#### *The other two: the body changes, not the shape*

{{code:code/u5/varios-objetos/01-sin-analysis-port/histogram.svh|lines=11-13}}

{{code:code/u5/varios-objetos/01-sin-analysis-port/coverage.svh|lines=14-17}}

- `histogram` keeps the rolls in an associative array and draws the bars in the
  `report_phase`
- `coverage` copies the roll into `the_roll` and calls `sample()`: it is the
  covergroup of the conventional testbench, with the sampling tied to the data
  instead of to the clock
- The three `write()`s are different on the inside and **identical on the
  outside**: same name, same argument. That is what is going to let us treat them
  the same

Note:
The point of the slide is the last bullet: three classes that look nothing alike
expose the same door. When `uvm_subscriber` shows up, that door is going to be a
contract of the language instead of a convention.
The `coverage` here is the answer to a question left open in the conventional
testbench: *where do I sample?* Here the `sample()` is not tied to a clock edge,
it is tied to **a piece of data having arrived**. That is the right thing, and it
is what the `coverage` of every testbench of the course does from here on.
The whole file of each one is in
`code/u5/varios-objetos/01-sin-analysis-port/`: what is not shown is the
`report_phase`, which only formats.

---

## One producer, many listeners

#### *The producer: it rolls the dice and returns a number*

{{code:code/u5/varios-objetos/01-sin-analysis-port/dice_roller.svh|lines=1-23}}

- `dice_roller` randomizes two bytes with a `constraint` that keeps them between
  1 and 6, and returns the sum
- That is all it does, and it is right that it should be all: **it produces the
  data and knows nothing about who uses it**
- Look at what it does **not** have: not a handle to `coverage_h`, nor to
  `histogram_h`, nor to `average_h`. That list lives somewhere else, and that is
  where the problem is

Note:
It is worth stopping on the absence: the producer is already well written. It
does not need fixing, and in fact in the version with an analysis port it barely
changes.
The `void'(randomize())` deserves a comment in passing: it throws away the return
value on purpose. In the transactions we are going to see why that is a bad habit
—a `randomize()` that fails and nobody finds out— and how it gets written
properly.
The question to leave hanging: if the producer does not have the list, who does?
The slide that follows.

---

## One producer, many listeners

#### *The one handing it out: the test, and it should not be*

- The `dice_test` extends `uvm_test`, instantiates the four components and starts
- It works. But look at the `run_phase`, and in particular at what is inside the
  `repeat (20)`

{{code:code/u5/varios-objetos/01-sin-analysis-port/dice_test.svh|lines=16-32}}

Note:
This slide is the "before", and it has to be allowed to look ugly. Look at the
`repeat (20)`: three `write()`s written out by hand, one per observer. Adding a
fourth means touching this class; removing one, too.
Worse still, and it is what is worth pointing at: the one left in charge of
handing out the data is **the test**. Which means the `dice_roller` produces and
the test distributes — two responsibilities that have no reason to be together,
and the distributing one is the one that is going to change all the time.
The question to throw out before moving on to the next one: if this were the
VTALU, who would the `dice_roller` be and who the three `write()`s? The monitor,
and the scoreboard plus the coverage. The analysis ports are literally this slide
with other names.

---

## One producer, many listeners

#### *Observer Design Pattern*

- Whoever publishes a tweet does not know who reads it or what they do with it,
  and yet it reaches everybody. That is the **Observer**
- An object produces a piece of data and publishes it. The ones who need that
  data subscribe. The producer **does not keep the list**
- Here the observed one is `dice_roller_h`; the observers —*subscribers*— are
  `coverage_h`, `histogram_h` and `average_h`
- The property that buys everything: adding a fourth observer **does not touch
  one line** of the one producing

![One emitter publishes and N observers receive](res/funs/observer-broadcast.svg)
<!-- .element: class="grande" -->

Note:
The analogy works better the other way round: the one who publishes does not know
who reads them, and that is exactly the property you want in a monitor. Adding a
new subscriber —another coverage, a log— does not touch one line of the one
producing the data.
The dice example is deliberately foreign to hardware: you see the pattern without
the noise of the protocol.

---

## One producer, many listeners

#### *The pattern, ready-made: the two ends of the wire*

- UVM brings the pattern ready-made, in two classes that are the two ends of the wire:
  - *uvm_analysis_port:* Sends data to a set of subscribers (observers)
  - *uvm_subscriber:* An extension of uvm_component that lets the component subscribe to a uvm_analysis_port

![A uvm_analysis_port publishing towards several uvm_subscriber](res/diagrams/varios-objetos_ports.svg)
<!-- .element: class="grande" -->

Note:
The names cost a minute and save half an hour later: **port** is the end of the
one producing, **export** the end of the one consuming, and the `connect()` is
always called on the port.
`uvm_analysis_port` is a *broadcast*: it does not care whether it has zero, one
or ten subscribers, and writing to an unconnected port is not an error — the data
is lost in silence. It is one of the silent traps of the course, and the symptom
is a scoreboard that never reports anything.
`uvm_subscriber` is the other end and it is a parameterized class: `#(int)` here,
`#(command_transaction)` in the analysis ports. The connection ends up **typed**
by the compiler, not by a string.

---

## One producer, many listeners

#### *uvm_analysis_port*

- We declare a variable of type *uvm_analysis_port* that states the type of data it is going to carry
- We instantiate the analysis port in *build_phase*
- We write data into the port through the *.write()* method
- Once we write data into the port, it goes to all of its subscribers
- We use the *connect()* method to connect the subscribers to the port. This method takes a single argument: an analysis_port

{{code:code/u5/varios-objetos/02-con-analysis-port/con-analysis-port.sv}}

Note:
Three steps and no more: declare the port, instantiate it in build_phase, write
with write(). On the other side the subscriber implements write() and gets
connected in connect_phase.
The detail that surprises: ports are not created with the factory, they are
instantiated with new().

---

## One producer, many listeners

#### *uvm_subscriber*

- We extend the *uvm_subscriber* class parametrically, so that it knows what type of data it is going to read
- The class gives us an object called *analysis_export*
- The class requires us to write a method called *write()* that takes a single argument *t*, of the same type as the extension of the class
- In our example, we have 3 subscribers (average, coverage and histogram)

{{code:code/u5/varios-objetos/02-con-analysis-port/coverage.svh}}

Note:
`uvm_subscriber` is a deal in two parts and it is worth stating it that way: **I
give you an `analysis_export`, you give me back a `write()`**. Nothing else. The
`analysis_export` is neither declared nor instantiated — it comes with the class.
The `#(int)` of the `extends` is the parameterized classes getting collected
again: it defines what type the `t` of the `write()` is, and the compiler takes
care that a port of `int` cannot be connected to a subscriber of something else.
The connection is **typed**, it is not a string.
Comparing it with the previous version of this same class is worth it: the
`write()` is identical. The only thing that changed is who it inherits from and
who calls it. That is the entire point of the section — the observer never finds
out that it is now an observer.
And a detail that shows up in the output: here the coverage is read with
`get_inst_coverage()`, not with `get_coverage()`. It is a Verilator limitation
—the type-wide one always returns 0— and it is in `docs/verilator.md`.

---

## One producer, many listeners

#### *The producer, publishing now*

{{code:code/u5/varios-objetos/02-con-analysis-port/dice_roller.svh|lines=20-39}}

- The three numbered steps are everything that changed with respect to the
  previous version: declare the port, instantiate it in `build_phase`, write with
  `write()`
- `roll_ap = new(...)`: ports are **not** created with the factory. They are the
  wiring of the testbench, not interchangeable pieces
- The `two_dice()` that returned a number is gone: now the roll gets published
  and the producer carries straight on

Note:
The comparison with the previous version is the whole slide: the `dice_roller`
did not gain a handle to anybody. It gained **one** port.
Why ports go with `new()` and not with `type_id::create()`: the factory is there
to substitute types, and a port never gets substituted. It is a question that
always comes up and that is the short answer.
And the `write()` here is worth looking at with inter-thread communication in
mind: it is a `function`, so it **consumes no time** and it runs in the
producer's thread. When the one consuming needs to make the one producing wait,
this is not enough.

---

## One producer, many listeners

#### *connect_phase(): where the wiring gets assembled*

- We need to link the producer with the consumer
- UVM provides a phase method (*connect_phase()*) to connect the objects
- UVM calls the build_phase method TOPDOWN, and once it is done with every object in the hierarchy, UVM calls the connect_phase method BottomUP
- The connection process has 2 fundamental parts
  - uvm_subscribers contain an object called analysis_export, which we must not instantiate since it comes along when we extend the uvm_subscriber class
  - The uvm_analysis_port class provides a method called connect()

Note:
The order of the two phases is not an implementation detail, it is what makes
this work: you cannot connect what does not exist yet. That is why `build_phase`
is top-down and finishes **entirely** before the first `connect_phase` starts.
That `connect_phase` is bottom-up matters less in practice, but it has its
reason: a composite component connects its children to each other only once every
child has connected its own. In the agents, when the agent connects driver and
sequencer inside itself and the env connects the agent outwards, it will show.
The `analysis_export` that shows up on its own is one of the few things in UVM
that come free: it comes with the class, and forgetting to instantiate it is not
a mistake because there is nothing to instantiate.

---

## One producer, many listeners

#### *connect_phase(): where the wiring gets assembled*

- A single line of `connect_phase()` hooks the subscriber up to the analysis
  port: `ap.connect(sub_h.analysis_export)`

{{code:code/u5/varios-objetos/02-con-analysis-port/dice_test.svh|lines=15-28}}

Note:
This is the "after", and it has to be put next to the "before" from five slides
back. The `run_phase` of the test is left without the three `write()`s: now it
only raises the objection and starts the producer. The distribution moved to the
`connect_phase`, which is where the structure goes.
The line to read slowly is
`dice_roller_h.roll_ap.connect(coverage_h.analysis_export)`, and the direction
matters: **the port connects to the export, never the other way round**. It is
the mantra that comes back in threads, in put and get and in agents, and the
compiler does not always catch you.
Pocket rule to remember the direction: the one that **produces** connects. The
one that consumes lends an ear and does nothing.
And the acid test of the section: to add a fourth observer you have to write the
class and **one** line here. Not one in `dice_roller`.

---

## One producer, many listeners

#### *The solution, wired up*

- In the connection diagram we can see that the dice_roller class has a uvm_analysis_port object called roll_app
- Each subscriber has an analysis_export object
- The connection between the two is made through the connect() method

![The dice example wired up with analysis ports](res/diagrams/varios-objetos_spicy.svg)
<!-- .element: class="grande" -->

Note:
It is the first TLM diagram of the course and it is worth teaching how to read it
now, because the ones from the rest of the day and the one from the agents use
the same convention: **diamond** is analysis port, **square** is put/get port,
**circle** is export. The arrow goes from the one producing to the one consuming.
What has to be pointed out about the drawing is that three arrows come out of the
`roll_ap` and **a single line of code** comes out of the `dice_roller`: the
`write()`. The multiplicity is not in the producer, it is in the wiring.
And the closing of the section, which links to the next one: all of this happened
inside a single thread. `write()` is a `function`, it cannot have an `@` or a
`#`, and it came back before time moved. When the one producing and the one
consuming have to wait for each other, this is not enough — and that is
inter-thread communication.

---

## One producer, many listeners

#### *Summary of the unit*

- Two objects talk to each other in **exactly two ways**, and the difference is
  whether they run in the same thread or not
- **Same thread**: one calls the other's method and comes straight back. It is a
  `function`, **it cannot block**. It is the `write()` of an analysis port
- **Different threads**: they have to be coordinated and somebody is going to
  wait. It is a `task`, **it can block**. It is `put`/`get`, and they are the
  last two sections
- The question in front of any UVM port is always the same: **can this block?**
  The signature tells you before you read the implementation
- The **analysis port** solves the underlying problem: the one who publishes
  **does not know who reads it**, and adding a reader does not touch one line
- It is the same old *observer* pattern, and it is the same move the BFM made in
  interfaces and BFM: one level up

Note:
The slide to open and close day 4 with, because it is the map. Write the two
columns on the board and come back to them every time a new port shows up.
And the criterion that orders the whole vocabulary: `write()` is a `function` —it
consumes no time—, `put()` and `get()` are `task`. In SystemVerilog that is not a
naming convention, it is the language telling you which side you are on.
