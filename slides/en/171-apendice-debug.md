<!-- es-sha: d485ca9d682c -->
<!-- .slide: id="apendice-debug" data-machete="res/en/machete-debug.svg" -->

## Appendix · The debug toolbox

#### *The tools we saw, all together*

| Tool | What for | Where it came up |
| --- | --- | :-- |
| `VLT_TRACE=1` + GTKWave | see the real signals | The VTALU spec |
| `+UVM_VERBOSITY=UVM_HIGH` | see the messages of the monitors | Reporting |
| `+UVM_CONFIG_DB_TRACE` | who put what in the `config_db`, and who read it | Agents |
| `+TOPOLOGY` → `print_topology()` | the tree UVM **actually** built | Agents |
| `+UVM_OBJECTION_TRACE` | who raised and who dropped the objection | Tests |
| `+UVM_TIMEOUT=N,NO` | a ceiling for the hang, instead of waiting | Tests |
| `+UVM_MAX_QUIT_COUNT=N` | kill the run at the Nth error | Reporting |

- The bottom six are **plusargs**: no code gets touched and nothing gets recompiled. On a
  testbench with UVM that is minutes of difference per attempt

Note:
This appendix exists because the tools are spread over four
sections and they are all needed together, at the worst moment: when something does not work and
the clock is running. It is the slide worth printing — and in fact it is already printed:
`docs/en/uvm-cheatsheet.pdf` is this table, the class hierarchy, the nine phases and
the handshake of the driver on a single A4 side. The source is `res/en/machete.html`,
it opens with a double click and it prints with Ctrl+P.
The point to say out loud is the one about the plusargs. A `$display`
added by hand costs a recompilation of UVM —minutes— and on top of that you have to
remember to take it out. These seven knobs are already fitted in the binary you
compiled: they get switched on from the command line and they leave no trace.
And one detail of `+UVM_TIMEOUT` that bites, because it does not error out: the value
is an integer in time units, not an expression with a unit. UVM reads it with
`$sscanf(…, "%d,%s")` (`uvm_root.svh:916`), so `+UVM_TIMEOUT=5ms` does not complain:
it takes the `5` and cuts the simulation off at 5 ns. You write
`+UVM_TIMEOUT=5000000,NO`, and the `NO` is so that a `set_timeout()` written in the
testbench does not overwrite what you asked for on the command line.
`+TOPOLOGY` is not from UVM: it is from the `base_test` of the course, which reads the plusarg and
calls `uvm_root::get().print_topology()`. It is worth clarifying so nobody
looks for it in the LRM. The same for `VLT_TRACE=1`, which is from the `run.sh`.
And one that is not in the table because it is not a tool but a habit:
running with `SEED=N`. A bug that shows up once every ten runs does not get debugged
until you can repeat it at will.

---

## Appendix · The debug toolbox

#### *Which one to use, according to the symptom*

| The symptom | The first suspect | What to look at it with |
| --- | --- | --- |
| It ends at **t=0** and says PASS | nobody raised the objection | `+UVM_OBJECTION_TRACE` |
| It **never ends** | an `item_done()` that was not called, or an objection that does not get dropped | `+UVM_TIMEOUT=5000000,NO` and then the trace |
| The scoreboard **screams on every one** | the monitor samples badly — the DUT hardly ever is the problem | `+UVM_VERBOSITY=UVM_HIGH` |
| The `config_db` **does not find** | the scope of the `set()`, not the `get()` | `+UVM_CONFIG_DB_TRACE` |
| The coverage gives **0 %** | the `new()` or the `sample()` of the covergroup is missing | read the `.dat` with `verilator_coverage` |
| The tree **is not the one you drew** | a `create()` without the factory, or a late override | `+TOPOLOGY` |

- The golden rule is in the second column: **suspect number one is never
  the DUT.** It is the testbench watching it

Note:
This slide is the index of the previous one, and the order of the rows is not accidental: they are
the six things that actually happen, ordered by how many times you are going to
see them.
The first and the second are two sides of the same coin: the objection. If nobody raises it,
the sim ends at zero; if nobody drops it, it never ends. That is why the objection
trace is the first tool to switch on when the simulation time
makes no sense.
The third is the one from the day 5 exercise, and the lesson it leaves is a matter of craft, not
of syntax: a monitor that samples on the wrong edge invents failures that
do not exist and makes you lose days. Before opening the RTL, look at what the monitor says
it saw.
The fourth has a trap inside the trap: `get(null, "*", ...)` does not fail
—it gives back the first thing it finds— so the symptom is not "it does not find", it is
"it found somebody else's". The trace shows it; the `get` does not.
And to close: the last column is all there is. If the symptom is not here,
the next step is the waveforms, which is the tool that does
47 % of the work.
