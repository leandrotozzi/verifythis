<!-- es-sha: d1a0eb738104 -->
## A single place that watches the wire

#### *A single place that watches the wire*

- Today the scoreboard and the coverage each watch **the signals** on their own:
  both wait for `done`, both read `op_set`, both know the protocol
- That is the same code written twice, and the day the protocol changes you have
  to remember both places
- The missing piece has a name in the industry: the **monitor**. A single one
  watches the bus, assembles the transaction and publishes it
- The scoreboard and the coverage become **subscribers**, like the dice of the
  previous unit: they never touch a wire again
- In UVM jargon those two form the *analysis layer*, and that is where the name
  `uvm_analysis_port` comes from

Note:
It is the same pattern as the dice, now on the DUT — and that is the whole section.
What has to be stressed is where the dividing line of the testbench runs, because
it is the one that orders everything that comes after: **on one side of the
monitor you speak in signals, on the other in transactions.** The BFM of
interfaces and BFM did that for the stimulus; the monitor does it for the
analysis.
The practical consequence is worth saying out loud: from here on, any analysis
component can be written without knowing anything about the protocol. A new
subscriber does not need to know that a `done` exists.
And the one that only shows up in the agents: if everything that knows how to
speak the protocol is together —BFM, monitors, driver—, that box can be
instantiated twice. That is the agent, and this section is the one that gathers
the pieces.

---

## A single place that watches the wire

#### *Which pieces show up*

- **`command_monitor`** — watches the start of every operation and publishes what was asked for
- **`result_monitor`** — watches the `done` and publishes what the DUT answered
- The **BFM** stops being only signals: it gains three `always` and a handle to each monitor
- The **scoreboard** and the **coverage** stop waiting for edges and get a
  `write()` instead
- The **`tester`** never finds out about any of it: it goes on sending stimulus just like yesterday

Note:
The slide is the inventory of the section and it is worth using it as a map:
there are five pieces and only two are new. It is worth saying out loud which
ones, because the student tends to believe that a new topic rewrites the whole
testbench.
That there are **two** monitors and not one is the decision that gets asked about
the most, so better to get ahead of it: they watch different things and at
different moments. The `command_monitor` watches when an operation starts; the
`result_monitor`, when the DUT answers. Between those two instants there are
cycles in the middle, so they cannot be the same `always`.
And the last bullet is the one to underline, because it is the promise the
section keeps: the `tester` **does not get touched**. All the work of this
section happens on the analysis side, and the stimulus side never finds out. It
is the first time the course separates the two halves of the testbench, and in
the section that follows the other one gets done.

---

## A single place that watches the wire

#### *Testbench diagram*

![The VTALU TB with analysis ports](res/diagrams/analysis-ports_fig102.svg)
<!-- .element: class="grande" -->

---

## A single place that watches the wire

#### *The handles the BFM keeps*

- Up to now the class read the interface. Here it flips around: **the interface
  keeps a handle to the class** and it is the interface that calls the method

{{code:code/u5/analysis-ports/vtalu_bfm.sv|from=interface vtalu_bfm;|to=op_set;}}

- These handles are set by each monitor in its `build_phase`, right after pulling
  the BFM out of the config_db

{{code:code/u5/analysis-ports/tb_classes/command_monitor.svh|lines=6-16}}

Note:
This slide holds the inversion that costs the most in the section and it is worth
saying it slowly: up to now **the class read the interface**. Here it is the
other way round — the interface has a handle to the class
(`bfm.command_monitor_h = this`) and it is the interface that calls the method.
The reason is that an `always` of the interface **can** have a sensitivity list,
and a class function cannot. We need the hardware to give notice; for that the
hardware has to know who to give notice to.
The line that does everything is `bfm.command_monitor_h = this`, and it goes in
the `build_phase`. If you forget it, the monitor compiles, runs, and never
publishes: the scoreboard is left without commands and the `uvm_fatal` shows up
on the other side, in a class that is not to blame. It is one of those errors
that get hunted in the wrong place.
A detail that helps: the handle is to the class, not `virtual`. That is why the
`always` can call `write_to_monitor()` directly without the Verilator hole that
affects tasks — here the one declaring the task is the class, not the interface.

---

## A single place that watches the wire

#### *Monitoring the VTALU commands*

- Three `always` in the BFM: the command one fires when an operation starts, the
  reset one on the falling edge of `reset_n`, and the result one when the DUT
  raises `done`

{{code:code/u5/analysis-ports/vtalu_bfm.sv|from=// Here is the first monitor|to=end : rslt_monitor}}

- And on the other side, the method they give notice to: it packs the `command_s`
  up and publishes it on the analysis port

{{code:code/u5/analysis-ports/tb_classes/command_monitor.svh|lines=18-26}}

Note:
The three `always` are the seam between the hardware and the classes, and it is
worth reading the condition of each one: the command one fires when `start` goes
up and there was no command in flight; the reset one, on the falling edge of
`reset_n`; the result one, when the DUT raises `done`.
The guard `if (command_monitor_h != null)` is not paranoia: at time 0 the UVM
tree does not exist yet and the `negedge reset_n` has already arrived. Without
the guard it is a null pointer from the simulator.
The `write_to_monitor()` is short on purpose: it assembles the `command_s`, logs
it with `UVM_HIGH` —which means it is only visible with
`+UVM_VERBOSITY=UVM_HIGH`— and calls `ap.write()`. Everything else happens on the
other side of the port, and the monitor does not know who is over there.
And the detail that gets collected in the transactions: what travels is still a
`struct`. The day it is a transaction, this same line is going to be a
`create()`.

---

## A single place that watches the wire

#### *The VTALU Coverage Class as a Subscriber*

- With the `command_monitor` there is **a single place** in the whole testbench
  that knows what a command looks like on the wire
- Whoever needs to know which operation ran subscribes to its analysis port and
  implements `write()`. They never look at a signal again

{{code:code/u5/analysis-ports/tb_classes/coverage.svh|from=// With the analysis port this is far simpler|to=endfunction : write}}

Note:
It is worth opening the `coverage` class of the object-based testbench alongside
and comparing: over there was a `forever` waiting for edges; here there is a
`write()` and nothing else. The coverage stopped having any notion of time.
And that is not cosmetic, it is the answer to the question left open in the
conventional testbench: **where the sampling happens**. Before, it sampled on the
clock, which means cycles got counted; now it samples when the monitor sees a
command, which means **operations** get counted. That is the right thing, and the
coverage number changes meaning.
The question for the group: if the DUT sat ten cycles doing nothing, how many
samples did the old version take and how many does this one? Ten and zero. The
old one was filling bins with nothing.

---

## A single place that watches the wire

#### *Subscribing to multiple analysis ports*

- The basic UVM analysis port mechanism lets a uvm_subscriber grab a single analysis_port
- However, in cases like a scoreboard, we need one and the same component to receive data from 2 analysis ports
- The reason for the limit: `uvm_subscriber` gives you **a single** `write()`, and
  that is the method the port calls. Two ports have nowhere to come in
- UVM solves it without splitting the component, with the *uvm_tlm_analysis_fifo* class
- It is parameterized and it has two faces: an *analysis_export* on one side
  —which gets connected like any subscriber— and a `try_get()` on the other
- `try_get()` takes an element out and returns 0 if the FIFO is empty, without blocking
- Which means: it turns *"they tell me when it arrives"* into *"I go and get it when I need it"*

Note:
The scoreboard needs two sources —the command and the result— and a
uvm_subscriber can listen to only one. The FIFO turns "they tell me when it
arrives" into "I go and get it when I want", which is what it needs in order to
compare in pairs.

---

## A single place that watches the wire

#### *Subscribing to multiple analysis ports*

- Scoreboard class:

{{code:code/u5/analysis-ports/tb_classes/scoreboard.svh|from=uvm_tlm_analysis_fifo #(command_s) cmd_f;|to=endfunction : write}}

Note:
The scoreboard is asymmetric and that is where the whole point is: the **result**
reaches it through `write()` —it gets pushed— and the **command** it goes and
fetches itself with `try_get()` from the FIFO. One is push, the other is pull.
Why like this and not two `write()`s: a `uvm_subscriber` has a single `write()`,
and besides the order matters. The scoreboard does not want to be told about the
command when it arrives; it wants it at the moment the result appears, so that it
can compare in pairs. The FIFO turns "they tell me" into "I go and get it when I
want".
The `do ... while` that skips `no_op` and `rst_op` is the part that gets copied
wrong: those two operations **produce no result**, so if they are not thrown
away, the comparison shifts by one place and from there on everything fails. The
symptom is a scoreboard that screams on every line, and it is exactly the day 5
exercise.
And the `uvm_fatal` of the `try_get()` is not paranoia: if there is a result and
there is no command, the broken one is the testbench, not the DUT. Better to die
there than to report a thousand false errors.

---

## A single place that watches the wire

#### *The other way: `` `uvm_analysis_imp_decl ``*

```systemverilog
`uvm_analysis_imp_decl(_cmd)        // makes the class uvm_analysis_imp_cmd
`uvm_analysis_imp_decl(_result)

class scoreboard extends uvm_component;
   uvm_analysis_imp_cmd    #(command_s, scoreboard) cmd_imp;
   uvm_analysis_imp_result #(shortint,  scoreboard) result_imp;

   function void write_cmd(command_s t);    ... endfunction   // one write per port
   function void write_result(shortint t);  ... endfunction
endclass
```

- The macro **generates a class** for each suffix, and each one calls a different
  `write_`: that way a component receives from two ports without a FIFO
- It is what you are going to see in most production code, so **you have to be
  able to read it**
- The course uses the FIFO anyway, for an underlying reason: `write_cmd()` runs
  **when the command arrives**, and the scoreboard needs it **when the result
  arrives**. The FIFO gives it that control; the macro forces it to keep the data
  by hand

Note:
Same treatment as the `` `uvm_field_* `` macros of the components and as
`` `uvm_do `` of the sequences: they get named, they get explained, and it gets
said why the course does not use them. The rule of the course, once again:
**read them all, write the explicit ones.**
What the macro hides and is worth saying: `uvm_analysis_imp` is a class that
already exists in UVM; the only thing `` `uvm_analysis_imp_decl `` does is
manufacture variants with a different name, because SystemVerilog does not let
you have two `write()`s in the same class. Which means the macro adds no
mechanism, it adds names.
Where it goes: in the package, **outside** every class, and only once per suffix
in the whole testbench. Declaring it twice with the same suffix is a compilation
error that shows up far from the place where you wrote it.
And the honest comparison: with the macro the scoreboard comes out shorter and
more coupled —it has to carry the command by hand until the result arrives—; with
the FIFO it comes out one line longer and it decides the order itself. For a
scoreboard that matches things up in pairs, the FIFO wins. For a component that
only counts things from two ports, the macro is better.

---

## A single place that watches the wire

#### *Subscribing to the monitors*

- We connect the analysis ports to the monitors using the connect_phase() method in the env class:

{{code:code/u5/analysis-ports/tb_classes/env.svh}}

Note:
Three `connect()`s and there is the whole testbench. Worth reading them out loud
as sentences: *the result goes to the scoreboard*, *the command goes to the
scoreboard's FIFO*, *the command also goes to the coverage*.
The surprising one is the second:
`command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export)`.
The export does not belong to the scoreboard, it belongs to **the FIFO the
scoreboard has inside it**. A `uvm_analysis_port` can have several destinations
—the `ap` of the command_monitor feeds two— and it costs it nothing: `write()`
walks through all of them.
And the detail that gets forgotten and gives no warning: `cmd_f` is instantiated
with `new()`, not with the factory. FIFOs and ports are not registered. If you
forget the `new()` the `connect()` blows up with a null, and that one at least is
an honest error.

---

## A single place that watches the wire

#### *When the DUT does not answer in order*

- The scoreboard of this section does a `try_get()` from a FIFO: the first command
  that went in is the one that matches the first result that came out. That holds
  because **the VTALU answers in order**, one operation at a time
- A real bus does not. In AXI every transfer carries an **ID** and the responses
  can come back crossed over: the FIFO starts comparing the response of one with
  the request of another, and screams on every one

```systemverilog
transaction expected [int];              // associative, indexed by whatever pairs them up

function void write_cmd(transaction c);  expected[c.id] = c;  endfunction

function void write_result(response r);
   if (!expected.exists(r.id)) `uvm_error("SB", "a response nobody asked for")
   else begin compare(expected[r.id], r); expected.delete(r.id); end
endfunction
```

- The pattern is always the same: **a table indexed by whatever pairs them up**, a
  `delete` once it has been compared, and at the end of the run the table **has to
  be left empty**
- That check at the end is half the value: what stayed inside are the requests the
  DUT never answered

Note:
The question that opens the slide is the one to ask of anybody else's scoreboard
before trusting it: *"and what if the DUT answers out of order?"*. The one in
this section falls over, and it is fine that it falls over — the VTALU does not
do that. What is not fine is not knowing it.
The symptom when it happens is cruel and worth anticipating, because it sends you
hunting in the wrong place: it is not **one** comparison that fails, it is
**every** one after the first crossed-over one. The testbench says a thousand
errors and the DUT has zero. It is the row *"the scoreboard screams on every
one"* of the debug appendix, with another cause.
The associative array is the canonical answer and there is no mystery to it; what
always gets forgotten is the `check_phase` that verifies it was left empty.
Without that, a DUT that stops answering passes green: there is never a bad
comparison, there are simply comparisons that were not made. It is the same hole
as the `drain_time` of the tests, seen from the other side.
And the variant that shows up when there is no ID: pairing by content. You keep a
queue of expected ones and look for the one that matches, instead of the first.
It is more expensive and it has a trap of its own —two identical transactions—,
and that is why the ID exists.

---

## A single place that watches the wire

#### *On one side of the monitor you speak in signals, on the other in transactions*

- The **monitor** is the only class that knows a `clk` exists. Coverage and
  scoreboard receive data and have no idea where it came from
- The Observer of talking to several objects, applied to the DUT: the monitor
  publishes and does not keep the list. Adding an observer is one line in the
  `connect_phase`
- And the limit, which is the section that follows: all of this happens in **a
  single thread**. The `always` of the BFM calls `write_to_monitor()`, which
  calls `ap.write()`, which calls the `write()`s of the subscribers — a chain of
  functions, without time moving

Note:
The sentence in the title is the real summary of the section and it is worth
leaving it written up: **on one side of the monitor you speak in signals, on the
other in transactions.** That border is what makes it possible for the scoreboard
of the transactions to exist without looking at a wire.
The third bullet is the hinge towards inter-thread communication: since it is all
a chain of `function`s, no link can wait. If the one consuming needs to make the
one producing wait —or the other way round—, something else is needed, and that
is the `uvm_tlm_fifo`.
Worth asking the question before moving on: what would happen if the `write()` of
a subscriber had an `@(posedge clk)` inside it? It does not compile. A `function`
cannot consume time, and that is the whole limitation.

---

## A single place that watches the wire

#### *Summary of the unit*

- Up to yesterday the scoreboard and the coverage each watched **the signals** on
  their own: the same protocol code written twice
- The piece that was missing has a name in the industry: the **monitor**. A single
  one watches the wire and **publishes** what it saw
- There are two: **`command_monitor`** publishes what was asked for,
  **`result_monitor`** publishes what the DUT answered
- The scoreboard and the coverage become **subscribers**: they stop waiting for
  edges and only implement `write()`
- That pair —monitors that publish, subscribers that analyse— is the **analysis
  layer**, and that is where the name of the port comes from
- The `tester` **never finds out about any of it**. That is the proof the split
  came out right: changing the analysis does not touch the stimulus
- And the scoreboard with a FIFO holds **as long as the DUT answers in order**.
  When it does not, the pattern is a table by ID that has to be left empty at the end

Note:
Closing of the unit where the testbench takes the shape it is going to have until
the end. Worth saying it like this: from here on, every time something new has to
be analysed —one more coverage, one more checker— the answer is always going to
be the same, **hang a subscriber off it**, and never touch the monitor.
It is literally the exercise of the day, and it is also what is going to be left
outside the agent in the agents.
