<!-- es-sha: 36c644536e96 -->
## Transactions

#### *The testbench is well divided up, and the data is not*

- The testbench is already well divided up, but **the data is still a `struct`**:
  `command_s` for the commands and a bare `shortint` for the results
- A `struct` does nothing by itself. Printing a command is a `$sformatf` written
  by hand, and it is written **four times**: tester, driver, coverage and
  scoreboard
- The same with randomizing and with comparing: every component builds its own,
  and the day the `struct` gains a field you have to remember all four
- And the result is not even a `struct`: it is a **bare** `shortint`, so the `ovf`
  of the VTALU —the second output— has nowhere to travel
- A class, on the other hand, has methods: the data and what gets done with it
  live together, and the rest of the testbench shrinks

Note:
The honest question from the student is "and why not a struct?". The answer: the
struct does not randomize itself, does not compare itself and does not print
itself. Everything the testbench used to do by hand with command_s becomes a
method of the class, and the rest of the testbench shrinks.
The fourth bullet is the most concrete argument and it is worth leaning on it: up
to here the analysis port of the result carries a `shortint`, that is to say **a
number**. The VTALU has two outputs —`result` and `ovf`— and that is why the
scoreboard of the previous units checks half the DUT and lets the other half
through. With a `result_transaction` with two fields, the check of the `ovf`
shows up on its own. It is the first time in the course that the class is not
tidiness: it is the only way.

---

## Transactions

#### *A transaction is data with the methods that operate on that data*

- It is the word the industry uses, and there is no magic class behind it: a
  **transaction** is that and nothing more
- The methods are four, and they are always the same:
  - `randomize()` — it fills itself in, respecting its `constraint`s
  - `convert2string()` — it prints itself
  - `do_copy()` — it copies itself
  - `do_compare()` — it compares itself
- What changes is not the data: it is **who knows things about it**. The `tester`
  used to know which values were legal; now it only says *"randomize yourself"*
- And the rest of the testbench shrinks: the four hand-written `$sformatf` become
  one call to `convert2string()`

Note:
The sentence on the slide is the definition to leave written on the board: **data
with the methods that operate on that data**.
The third bullet is the shift in the division of responsibilities of the section:
until today the `tester` knew which values were legal —it had a `get_data()` with
the bias written by hand—. From today that lives in the transaction, in a
`constraint`.
The question to throw out: if tomorrow the DUT accepts 16-bit operands, how many
classes have to be touched? One.


---

## Transactions

#### *Defining a transaction: which class it extends*

- Transactions are defined by extending the *uvm_sequence_item* base class and writing the following methods:
  - do_copy()
  - do_compare()
  - convert2string()
- What follows is turning the old `command_s` structure into a class,
  `command_transaction`, method by method

{{code:code/u6/transactions/command_s.sv}}

Note:
Careful with the base class, because the old material says something else. The
chain is `uvm_sequence_item` → `uvm_transaction` → `uvm_object`, and it is always
the first one that gets extended.
Two reasons. The small one: in IEEE 1800.2 `uvm_transaction` is a *virtual
class*, it cannot be instantiated on its own. The big one: a `uvm_sequence` only
knows how to send `uvm_sequence_item`. If the transaction extends plain
`uvm_transaction`, everything from day 6 —`start_item` / `finish_item`— does not
compile.
Which means the base class we pick today is the one that lets us go on tomorrow.

---

## Transactions

#### *The randomized fields: the "before"*

- Today the stimulus gets built with two hand-written functions, `get_op()` and
  `get_data()`, which draw the values with `$random` and `$urandom_range`
- The legal range of `A` and `B` and the bias to the edges are properties **of the
  data**, not of the test — and yet they live in the tester
- SystemVerilog already brings this ready-made, and there is no need to write a
  single `$urandom`

{{code:code/u6/transactions/prev-random.sv}}

Note:
It is worth reading this code as the "before" and asking the question before
giving the answer: which part of this belongs to *the test* and which part
belongs to *the data*? The legal range of A and B, and the bias to the edges, are
properties of the data — they have nothing to do with what you want to test.
The hand-written `$random` and `$urandom_range` are the symptom: every component
that wants a valid command has to repeat them. And if the DUT changes, all of
them have to be remembered.
The punchline for the next slide: SystemVerilog already brings this ready-made,
and there is no need to write a single `$urandom`.

---

## Transactions

#### *The randomized fields: the "after"*

- Every SystemVerilog class brings an implicit `randomize()`, which picks values
  for the fields marked `rand`
- `get_op()` disappears: an `enum` randomizes itself over its legal values
- `get_data()` too, and it gets replaced by a `constraint` with `dist`, which is
  where the bias to the edges gets declared

{{code:code/u6/transactions/tb_classes/command_transaction.svh|lines=1-24}}

Note:
Three things about this code, in the order in which they get forgotten.
`rand` in front of every field: without that the field does not enter the draw
and `randomize()` leaves it as it was, **without warning**. It is the first place
to look when a value always comes out the same.
The `dist` with `:/` and not `:=`: it reproduces the bias to the edges that the
`get_data()` of the conventional testbench did by hand. The difference between
the two operators is a whole unit of the course, and it is not a style detail —
with `:=` the `00` bin comes up 1 time in 256 and the corner cases never get
filled.
And the `op` with no constraint: an `enum` randomizes over its values, so `no_op`
and `rst_op` are going to come out too. That is on purpose — the verification
plan asks for operations after a reset.


---

## Transactions

#### *The constructor: a `uvm_object` has no parent*

- *uvm_sequence_item* extends *uvm_transaction*, and that one *uvm_object* — which means a transaction is **not** a *uvm_component*. It therefore has a simpler constructor
- A transaction **does not live in the tree of the testbench**: that tree is made
  of *uvm_components*, and it is the one UVM walks in `build_phase`. With no place
  in the tree there is no parent, and that is why the constructor only asks for a
  `name`
- Objects get created and destroyed all the time while the simulation runs;
  components get built once, before it starts, and they stay
- It is still worth giving them a name: it is the one that shows up in the UVM
  messages

{{code:code/u6/transactions/tb_classes/command_transaction_constructor.svh}}

Note:
It is the distinction that has to be left clear: *component* is structure —it is
in the tree, it has a parent, it has phases—; *object* is data —it gets created,
it travels around the testbench and it gets thrown away—. Both are UVM classes,
but only one of them builds the hierarchy.
A trick to remember it: if you can draw it in the block diagram of the testbench,
it is a component. If it travels along an arrow of the diagram, it is an object.

---

## Transactions

#### *`do_copy()`: copy the object, not the handle*

- `uvm_object` brings two ready-made methods: `copy()`, which pours the data onto
  another object **that already exists**, and `clone()`, which also creates the
  new object
- Both work only if the class implements `do_copy()`: the library knows how to
  copy, but it does not know **which fields** your transaction has
- It is the same pattern as the rest of the section: `copy()` is the one that gets
  called, `do_copy()` is the one that gets written
- The only difference is that UVM requires the argument we hand it to be called *rhs* (Right Hand Side)

{{code:code/u6/transactions/tb_classes/command_transaction_do_copy.svh}}

Note:
The pattern is the one from the class hierarchies, with two UVM rules on top.
The first one, the one that makes it compile: the argument is called `rhs` and it
is of type `uvm_object` —the base class of everything—, so the first thing to do
is cast it. And since the `$cast` checks at run time, it goes with its
`uvm_fatal`: if somebody tries to copy a `result_transaction` onto a
`command_transaction`, you want to find out right there and not three components
further on.
The second one: the `super.do_copy(rhs)` goes **before** touching your own
fields. It is the same discipline as in the class hierarchies and here it matters
more, because `uvm_object` has fields of its own that you do not see.
And the detail that confuses everybody: you write `do_copy()`, but you **never
call it**. The testbench calls `copy()`, which lives in `uvm_object`, and that one
takes care of invoking your `do_copy()`. It is the same division as the phases —
you put in the bottom part, the library handles the protocol.


---

## Transactions

#### *The MOOCOW rule: sharing yes, modifying no*

- Several components can see the same piece of data if they have handles to the
  same object. It is cheap and it works — as long as nobody modifies it
- The rule that holds it up is called **MOOCOW** —*Manual Obligatory Object Copy On
  Write*—, and that is how the Verification Academy names it
- It says this: sharing a handle is fine **as long as you do not touch the
  object**. Whoever wants to modify, copies first
- It is a discipline of the team, not something the language enforces. UVM only
  puts up the tool: `clone()`, which returns a `uvm_object` and has to be cast

Note:
The name is a joke from the Verification Academy, but the rule is the one that
avoids the most expensive bug of the class hierarchies: you sent the transaction
to the scoreboard, you still hold the handle, you modify it for the next one, and
the scoreboard ends up comparing against data that changed after it received it.
It does not fail every time — it fails under load, which is when it suits you
worst.
The practical version, without acronyms: **whoever produces the data does not
touch it again after publishing it.** If you need to change it, clone.
Look at how the `tester` of this section complies with it: it does not reuse the
handle. Every turn of the `repeat` does a fresh `create()`. It is cheaper than
cloning and it avoids the argument.
And there is one documented exception they are going to see on day 6: the driver
writes the result inside the item the sequence lent it. It is agreed between the
two parties and it is the only place in the testbench where that gets done.


---

## Transactions

#### *`clone_me()`: the `$cast` written a single time*

- Since `clone()` returns a `uvm_object`, every component that uses it ends up
  writing its own `$cast` — the same one, repeated
- The Verification Academy convention is to add a `clone_me()` to the transaction
  that does both things and returns the right type already
- UVM does not bring it: it is four lines written once in the data, so that none
  of the ones who use it have to remember the cast

{{code:code/u6/transactions/tb_classes/command_transaction_do_clone.svh}}

Note:
It is a three-line method and it exists for one reason only: `clone()` returns a
`uvm_object`, so everybody who uses it has to cast. Writing the `$cast` once
inside the class is better than writing it fifty times outside.
The name is not in the standard: `clone_me()` is a Verification Academy
convention. In somebody else's project it can be called something else or not
exist at all — and there you are going to see the `$cast` repeated in every
caller.
And the trap that has to be named: `clone()` calls `create()` and then `copy()`,
which ends up in your `do_copy()`. If `do_copy()` forgets a field, the clone comes
out incomplete and **nobody warns you**. It is the same hole as in the class
hierarchies, under another name.

---

## Transactions

#### *`do_compare()`: comparing two objects without writing an `if` per field*

- `compare()` comes with `uvm_object` and returns 1 if the two objects are equal.
  It is the one that gets called; the one that gets **written** is `do_compare()`
- It takes two arguments: the `rhs` —the other object— and a `uvm_comparer`, which
  is the comparison policy: how many differences to report and with what verbosity
- Almost nobody touches the comparer, but it has to be declared because the
  signature asks for it

{{code:code/u6/transactions/tb_classes/command_transaction_do_comparer.svh}}

Note:
Two things that get copied wrong.
The `$cast` here does **not** go with a `uvm_fatal`: if the type does not fit, the
right answer is `same = 0` —they are different, obviously, if they are not even of
the same class—, not killing the simulation. It is the difference with
`do_copy()`, where a wrong type really is a testbench bug. Worth showing them side
by side.
And the `super.do_compare()` goes **chained with `&&`**, not called and thrown
away. The classic mistake is to write `super.do_compare(rhs, comparer);` on a line
of its own and then `same = (A == rhs.A) && ...`: it compiles, it runs, and it
silently stops comparing everything from the class above.
The `uvm_comparer` of the second argument is the policy —how many differences to
report, with what verbosity—. Almost nobody touches it, but it has to be declared
because the signature asks for it.


---

## Transactions

#### *`convert2string()`: the transaction prints itself*

- It is the method that returns the object as text. It gets written **once**, and
  it is used by the scoreboard, the monitor and anybody who has to report
- `$sformatf()` builds the string with the same format specifiers as always
- And the detail that makes a log readable: an `enum` has `name()`, which returns
  `add_op` instead of `3'b001`. Without that the error says a number and nobody
  reads it

{{code:code/u6/transactions/tb_classes/command_transaction_convert2string.svh}}

Note:
It is the most used of the three methods, and the one that gets the least
attention: every message of the scoreboard and of the monitors of the rest of the
course comes out of here.
The `.name()` of the `enum` is the detail that changes the day: without it the log
says `op: 4` and you have to go looking for the `typedef`; with it it says
`op: mul_op`. The rule to take home: **if a field is an enum, the log gets its
name, never its value.**
Worth naming the relative UVM brings and the course does not use: `sprint()`,
which prints the transaction on its own if you registered the fields with the
`` `uvm_field_* `` macros. It comes out automatically, it comes out ugly —three
lines per field, with type and radix— and it cannot be adapted. A three-line
`convert2string()` written by hand fits in one line of the log, and in a file of a
hundred thousand lines that matters.


---

## Transactions

#### *The seven steps, and why there are seven*

What it costs to change the data type of a TB that already exists. We look at
**2, 3, 6 and 7**; **1, 4 and 5** are a direct port and are in the repo:

| # | What | Where |
| --: | --- | --- |
| 1 | a `result_transaction` for the way back | `result_transaction.svh` |
| 2 | an `add_transaction`, additions only | `add_transaction.svh` |
| 3 | the two testers merge into one | `tester.svh` |
| 4 | the `command_monitor` publishes objects | `command_monitor.svh` |
| 5 | the `result_monitor`, the same | `result_monitor.svh` |
| 6 | the `scoreboard` uses `compare()` | `scoreboard.svh` |
| 7 | `add_test` overrides the **data** | `add_test.svh` |

Note:
The seven steps are the most boring part of the section and also the most honest,
so it is worth framing them instead of rushing through them: **this is what it
costs to change the data type of a testbench that already exists.** The real
advice is to do it from the start.
The one to keep an eye on is number 3, because it is the only one that **deletes**
a class: `add_tester` disappears. That is where the result of the section is, and
it is worth announcing it — moving the decision into the data made a whole
structural class redundant.
If the group is going fast, steps 4 and 5 get opened in the editor and compared
with the ones from the analysis ports: the difference is that instead of filling a
`struct` there is a `create()` and fields get filled. Nothing else.


---

## Transactions

#### *Step 2 · an `add_transaction` that only adds*

- `add_transaction` extends `command_transaction` and adds **a single**
  constraint to it: `op == add_op`
- That is enough to change the stimulus, and the `tester_h` never finds out: it
  uses the child class exactly as it used the mother
- Constraints **are inherited and they accumulate**: the bias to the edges of `A`
  and `B` is still there, because the one in the base class does not go away

{{code:code/u6/transactions/tb_classes/add_transaction.svh}}

Note:
Eight lines, and out of those only one does anything:
`constraint add_only {op == add_op;}`. It is worth putting it next to the
`add_tester` of the env, which did the same thing by redefining a method. Two ways
of saying "additions only", and today's does not touch behaviour code — it only
describes which values are legal.
The conceptual point, which is the one that orders the day: **constraints are
inherited and they accumulate.** `add_transaction` does not replace `data`, it
adds to it. The solver has to satisfy both at once, so there is still bias to the
edges in `A` and `B` — and that is exactly what we want.
From there comes the warning: two inherited constraints that contradict each other
do not give a compilation error, they give a `randomize()` that returns 0. It is
case 1 of the Constrained random experiment.


---

## Transactions

#### *Step 3 · two testers become one*

{{code:code/u6/transactions/tb_classes/tester.svh|lines=14-34}}

- The testbench of the env had `base_tester` and `add_tester`: two classes for two
  kinds of stimulus
- Now there is **only one**. The `repeat` creates a transaction and tells it
  `randomize()`; what comes out of that is decided by the **data**, not by the
  tester
- That is the line that deletes a class: the decision moved from the structure to
  the type of the transaction

Note:
It is the result of the section, measured in files: `add_tester.svh` stops
existing. It is worth saying out loud, because the env had spent a while
justifying that hierarchy and now half of it is redundant.
And it is not that the env was wrong: it was the right answer while the data was a
mute `struct`. When the data knows how to randomize itself, that step of the
hierarchy runs out of work. It is a good example of abstractions being justified
against the problem of the moment, not forever.
The `if (!command.randomize()) uvm_fatal` is the line to copy properly:
`randomize()` returns 0 if the constraints have no solution and it aborts nothing.
There is a whole slide on that further on.

---

## Transactions

#### *Step 6 · the scoreboard compares objects, not numbers*

- Both sides of the comparison are now `result_transaction`: the one that arrives
  from the `result_monitor` and the one the predictor builds
- The `write()` takes the result `t`, looks for the command that corresponds to it
  in the `command_monitor` queue, and asks `predict_result()` for the prediction
- The comparison comes down to one line —`predicted.compare(t)`— and the error
  message builds itself out of the `convert2string()` of the three transactions

{{code:code/u6/transactions/tb_classes/scoreboard.svh|lines=30-53}}

Note:
Comparing this `write()` with the one from the analysis ports is the best way to
close the section: over there was a `case` with the prediction written inside it
and a hand-written comparison; here there is a `predict_result()` that returns an
object and a `predicted.compare(t)`.
What was gained is concrete: the error message is now built with
`convert2string()` of the three transactions, so it says what was sent, what came
out and what was expected, all with the enums by name. And the day the transaction
gains a field, the log shows it on its own.
A detail that has to be pointed out because it is the rule of the section applied:
the `predicted` comes from `type_id::create()`, not from `new()`. It is a
transaction that travels —even if it only travels as far as the `compare()` on the
next line—, so it comes out of the factory like all the others.
And the `do ... while` that skips `no_op` and `rst_op` is still the same as in the
analysis ports: those operations produce no result, and if they are not thrown
away the comparison shifts by one and everything fails. It is the day 5 exercise.


---

## Transactions

#### *Step 7 · the override, now on the data*

{{code:code/u6/transactions/tb_classes/add_test.svh}}

- The whole test is **two lines**: the override and the `super.build_phase()`
- And the override no longer changes a **component** —the tester— but a **piece of
  data** —the transaction—. The structure of the testbench stopped having an
  opinion about the test
- `super.build_phase(phase)` goes **after** the override, and that order is not
  negotiable: the env gets built in there

Note:
It is worth putting this slide next to the `add_test` of the env and counting
lines: the same idea, one level further down. Before, what generated was
substituted; now, what is generated is.
The order of the `super` is the trap of the slide, and it is a sibling of the one
in the env: the factory decides what to build at the moment of the `create()`. If
the override arrives afterwards, there is no error — the testbench runs with
`command_transaction` and the "additions" test sends random operations. It does
not break, it lies.
And a question that always comes up: why does `add_test` call `super.build_phase()`
here if the course says it is not needed? Because its base is `random_test`, a
class of **ours** that has a `build_phase` with real work in it. The rule from the
components was talking about `uvm_component`, which does not have one.

---

## Transactions

#### *The `new()` that eats the override*

```systemverilog
command = new("command");                                   // NO
command.op = rst_op;

command = command_transaction::type_id::create("command");  // YES
command.op = rst_op;
```

- `set_type_override()` talks **to the factory**, and the factory only finds out
  about what goes through `type_id::create()`
- A `new()` builds the type that line says and nothing else: the override **does
  not reach it**. It compiles, it runs, and it does not fail — that object simply
  got left out
- It is the worst kind of bug: it does not break, it **lies**. With one test and
  one transaction it never shows; the day the override really mattered, it is
  already too late
- The rule, short: **every `uvm_object` that travels around the testbench comes
  out of `type_id::create()`** — the transactions of the tester, and also the ones
  the monitors build and the `predicted` of the scoreboard
- The *ports*, the *exports* and the *TLM FIFO* are the exception: they are not in
  the factory and they get instantiated with `new()`, as we saw in one producer,
  many listeners

Note:
This slide comes out of a bug this very course had: the tester created the two
directed operations —the reset and the FF x FF multiplication— with `new()`, so
under `add_test` those two were NOT `add_transaction`. Nobody noticed because the
testbench works just the same.
The question to throw at the group, which is the one that orders everything: if
the reset now comes out of the factory and under `add_test` it is an
`add_transaction`, why does the constraint `op == add_op` not turn it into an
addition? Because we do not randomize it. **The factory picks the type;
constraints only act on `randomize()`.**

---

## Transactions

#### *And `randomize()` never goes on its own*

```systemverilog
assert (command.randomize());                                  // NO
if (!command.randomize()) `uvm_fatal("TESTER", "randomize() failed")  // YES
```

- `randomize()` returns **0** when the constraints have no solution. It does not
  abort, it prints nothing on its own: it returns 0 and carries on
- A bare `assert()` reports outside UVM: it does not go into the *Report Summary*
  —the same one we learned to read in reporting— and in many simulators execution
  carries on with the transaction **unrandomized**
- And if the project compiles with assertions turned off, there are simulators
  that do not even evaluate the expression: `randomize()` simply **never gets
  called**
- With `` `uvm_fatal `` the error brings component, time and file, and it stops the
  run right there

Note:
It is one extra line that pays for itself the first time somebody adds a
contradictory constraint. Without the `else`, the symptom is a scoreboard failing
on transactions with absurd values and half an afternoon spent looking for it in
the DUT.
The `` `uvm_fatal `` is not an exaggeration: an unrandomized transaction is not
bad stimulus, it is stimulus you did not choose. Better for the run to die with a
message than to tell somebody that last night's regression meant nothing.

---

## Transactions

#### *Summary of the unit*

- We saw how to use *transactions* to move data around the TB
- That lets us simplify the components of the TB and even remove a class from our initial TB (add_tester)
- The unit that follows groups the classes that talk to one and the same interface
  into a single reusable block: the `uvm_agent`

Note:
Closing of day 5, and it is worth saying what is missing: today the stimulus is
generated by a tester you wrote yourself; in modern UVM that is a uvm_sequence
running on a sequencer, and the set of driver + monitor + sequencer is packed into
an agent. That is day 6.
