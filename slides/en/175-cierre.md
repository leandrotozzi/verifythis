<!-- es-sha: 71028ffd7dd5 -->
<!-- .slide: id="cierre" -->

## This is as far as we got

#### *What you take with you*

- You know **why** verification exists as a discipline, and what the
  numbers of the industry say
- You wrote a conventional testbench, you measure it with **functional coverage**, and
  you know how to read the number that comes out
- You can read and write **OOP in SystemVerilog**: classes, inheritance,
  polymorphism, parameterized classes, the factory
- You built a **complete UVM testbench** —test, env, components, monitors,
  driver, scoreboard, transactions, agents and sequences— piece by piece,
  understanding what replaces what
- You wrote **assertions**: the other half of the plan, the one no scoreboard can
  close because it is not about the result but about the protocol
- And you handed it in: the **capstone** is a DUT you had not seen before, its
  spec, and the whole testbench from a blank sheet — which is literally what gets
  asked for at work
- And all of that runs on your machine, with **free tools**, without asking
  anybody for a licence

Note:
It is worth reading the list out loud and slowly, because after seven days nobody
has a sense of how much they saw. It is seven bullets and each one was a whole course
a week ago.
The one to underline is the last, and not out of activism: **all of this runs on
the student's machine**. There is no part of the course left in demo mode
because a licence is missing, and that means that the day they want to repeat an
example, try out an idea or show something to somebody, they can. Most of the
UVM material they are going to find from here on does not have that property.
And the honest clarification before the slide about what was left out, so nobody
leaves with the wrong idea: this is an **introductory** course, and what
follows is a list of what was not covered. Finishing it is not knowing UVM — it is being able to
read somebody else's testbench, write one of your own, and understand the next thing you
learn without it sounding like gibberish.

---

## What was left out

#### *and where to go on*

| Topic | Why you are going to run into it |
| --- | --- |
| `uvm_event`, `uvm_barrier` | The synchronization that is left when the objection is not enough |
| `uvm_heartbeat` | The one that warns you a component stopped showing signs of life in a regression of hours |
| `uvm_sequence_library` | A bag of sequences the sequencer picks from at random: the stress test without writing it |
| `uvm_pool`, `uvm_queue` | The collections of UVM. An associative array is enough until it has to be shared |
| **TLM2, phase jumps** | The limit of the course, and it is explicit |
| UPF, gate-level, PSS | Three worlds apart: low power, the netlist with delays, and generating the tests from a model |

- The three places to go on: the **LRM IEEE 1800-2017**, the *UVM User Guide*
  from **Accellera**, and **Verification Academy**
- And one almost nobody uses: the **code of `uvm-core`**. It is on your disk, in
  `code/.uvm/src/`, and by this point you can read it
- And if you get stuck: **[Discussions](https://github.com/leandrotozzi/verifythis/discussions)**,
  with one category per day. An example that does not run or an explanation that does not get
  understood are **issues of the course**, not problems of yours
- And if you want to go on right here: **day 8** is optional and starts on the slide
  that follows — RAL, the reference model in C, and a second capstone

Note:
**RAL came out of this table and is now unit 9**, optional, with the example that
runs in `code/u9/ral/` and the exercise `d8-ral`. It is on **day 8**, after
this slide and not in the middle, because it is only understood once the student has already
written the scoreboard RAL replaces — and because as far as we know it is the first course that shows it
running on a free simulator. What was left out of RAL, and is said in
the unit: the backdoor and generating the model from IP-XACT.
The **`clocking block`** also came out of this table: it is half a section of
unit 2, with its example that runs in `code/u2/clocking/`.
The **callbacks** came out for the same reason: they are half a section of unit 7, with
the `code/u7/callbacks/` that injects the error in the driver — the third hook
unit 1 promises. And **regression and seeds** as well: the exercise `d7-semillas`
is the whole cycle, and `make regresion` left it as a tool, with a report of
the bins that were left open.
**SVA came out of this table and is now a whole unit**, and it is one of the most original things
the course has: no introductory UVM book brings it. The **virtual sequences**
came out too: they are the first hour of today, with an example that runs in
`code/u7/sequences/virtual/`.
The last three rows are worth reading out loud with this sentence in front: an
introductory course that lists what it does not cover is worth more than one that pretends
to cover everything. `uvm_heartbeat`, the sequence library and the collections get understood
in an afternoon when they are needed; UPF, gate-level and PSS are another career.
The last line is not a joke. After this course the student can open
`uvm_component.svh` and understand what `build_phase` does, because they saw every piece
the library hands them built by hand.
If there is time, open it live and look together for the `m_set_full_name()` that makes
the config_db find things. It is the best way to close the course: the
library stops being magic.
