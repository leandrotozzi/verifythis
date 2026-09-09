<!-- es-sha: dedae37e2814 -->
<!-- .slide: id="glosario" data-machete="res/uvm_class_diagram.svg,res/diagrams/sequences_tb_completo.svg" -->

## Glossary · the words of the trade

#### *What it is called on the job, and not in the textbook*

| What a textbook says | What gets said at work |
| --- | --- |
| coverage of the functionality / of the code | *functional* / *code coverage* |
| the test plan | *verification plan*, *coverage plan* |
| reaching full coverage | *coverage closure* |
| edge cases | *corner cases* |
| hand-written / random stimulus | *directed* / *constrained-random stimulus* |
| signal plots | *waveforms* |
| the random number seed | *seed* |
| the nightly test run | *regression* |
| the first chips back · redoing the masks | *first silicon* · *respin* |
| a check written for the simulator | *assertion* — and `assert property` never gets translated |
| reading a signal at a given moment | *sampling* — and the edge it happens on, the *sampling edge* |
| test bed, test harness | **testbench**, always — nobody says anything else |

- The concepts are the ones in the course; these are the exact words that the LRM, the
  *User Guide* and every answer you are going to find use. This table is the bridge

Note:
This slide exists because between knowing a concept and being able to look it up there is a
vocabulary, and it is the one nobody teaches: the student has just learned the
concepts and from tomorrow every search, every question on a forum and every
interview goes through these exact words.
The last row is not a joke. "Test bed" and "test harness" turn up in translated books
and in software, and **nobody says them here**: in an interview or in a mail to the team you
say testbench. The same with *coverage*, *seed* and *tape-out*.
A rule of thumb for work: the technical nouns are fixed and do not get paraphrased.
"Randomize the transaction", "run the regression", "this does not close coverage". It sounds like
jargon and it is how the trade talks.

---

## Glossary · The pieces

#### *One line each, to have them together*

| Word | What it is |
| --- | --- |
| *handle* | the name of an object — it is **not** the object |
| *factory* | the dictionary of types: you ask for the base class and you get the derived one |
| *override* | changing the type the factory hands out, without touching whoever asks for it |
| *transaction* | a piece of data that travels through the testbench: a `uvm_sequence_item` |
| *agent* | everything that knows how to speak one interface, in a box |
| *sequence* / *sequencer* | the stimulus (object) and the arbiter that hands it out (component) |
| *virtual sequence* | the one that sends no items of its own: it coordinates **several** sequencers |
| *driver* | turns a transaction into signals |
| *monitor* | watches the bus and publishes transactions |
| *scoreboard* | compares what came out against what should have come out |
| *subscriber* | anybody listening to an analysis port |
| *objection* | the *"I still have work to do"* that keeps the phase alive |
| *assertion* | a rule of the protocol written so the simulator checks it |
| *property* | the rule itself: clock, antecedent, implication, consequent |
| *antecedent* / *consequent* | the *"if"* and the *"then"* of a property |
| *cover property* | counts **how many times a property got evaluated**. The check of the check |

Note:
It is the slide to keep open while reading somebody else's code, and also the one that
serves as a quick review before an interview.
The two rows that get confused the most are *sequence* and *sequencer*, and the way not to
get them wrong is the one from day 6: the one ending in **-er** is the **component** —it is in
the tree, it has phases—; the other is the object that gets created, runs and is thrown away. The
same holds for *driver* and *monitor*: all the ones ending in -er/-or are
components.
And the first row is the hardest one and the one that costs the most: *handle*. If the
student takes a single word away from this glossary, let it be that a handle is not an
object.
The *virtual sequence* row brings two more words along that are going to
show up in any production testbench: the *virtual sequencer*, which is a
component without a queue whose only contents are the handles to the real
sequencers, and `p_sequencer`, the handle already cast to that type that
`` `uvm_declare_p_sequencer `` declares for you.
A warning about *sequence*, which now shows up twice in the course with two
meanings: the UVM one is an object that generates stimulus; the SVA one
(`sequence ... endsequence`, the assertions) is a temporal expression —*"this, and three
edges later that"*— and has nothing to do with it. The context always tells them
apart, but the first time it confuses.

---

## Glossary · Three words that mislead

- **`virtual`** — in SystemVerilog it is **three unrelated things**: a *virtual
  method* (resolved by the object), a *virtual class* (abstract, it does not get
  instantiated) and a *virtual interface* (a handle to an interface). That they share
  the word is an accident of the language
- **`assert`** — in SystemVerilog it is **two things**: the *immediate* one, a statement
  that runs where the thread goes past, and the *concurrent* one (`assert property`), a
  declaration with a clock that gets evaluated on its own the whole simulation — the assertions. The
  `assert(randomize())` that is seen everywhere is the first one, and it is a poor
  way of checking a return value: that is why the course uses `` `uvm_fatal ``
- ***coverage*** — without a surname it means nothing. If somebody tells you "we are
  at 90 %", the question is always *code or functional?*
- And one of scale: a **test** in UVM is a **class**, not a file nor a
  run. The run is a *run*; the set of runs, a *regression*

Note:
The three are here because each one has already caused a confusion in the course, and
it is worth closing by naming them.
`virtual` was flagged in polymorphism and it comes back in the testbench in objects with the
virtual interface. The
question that sorts it out: virtual what? If it is a method, it looks at the object. If it is
a class, it does not get instantiated. If it is an interface, it is a handle.
The `assert` is the trap of the transactions and it is worth repeating why: it reports
outside UVM, it does not go into the Report Summary, and with the assertions switched off there are
simulators that do not even evaluate the expression — which means `randomize()` does not get called.
And the last row looks obvious until the first project meeting, where
"how many tests do you have" and "how many tests did you run last night" are two different
questions with two very different numbers.
