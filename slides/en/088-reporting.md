<!-- es-sha: 5f52e3174614 -->
## Reporting

#### *47 % of the time goes here*

- The first chart of the course said that almost half of a verification engineer's time
  goes into **debug**. This section is about that half
- A scoreboard that only says `FAIL` leaves you right there: you know something is wrong and
  you do not know which component, at what moment, or with what data
- The natural reaction is to fill the code with `$display`, and then delete them.
  And put them back next week
- UVM solves it the other way round: the messages **stay in** and get filtered. Each
  one brings along the time, the hierarchical path of the component and the file
- And there are two different knobs, which get confused all the time: **verbosity**
  filters `` `uvm_info ``; the **actions** control warnings, errors and fatals

Note:
It is worth going back to the day 1 chart before starting, because this section looks
like plumbing and it is the one that returns the most hours. The argument is not "nice
messages": it is that a message that brings along the hierarchical path saves you the question
"who said it?", which is half of any debug.
The second idea, which is the one that costs: debug messages **do not get deleted**. A
`` `uvm_info `` at UVM_HIGH costs nothing when the ceiling is at UVM_MEDIUM, and
the day you need it, it is there. That the day 5 exercise gets solved by raising
the verbosity is no coincidence — it is set up so that they live it.
And the distinction on the last line is worth writing on the board from the start,
because it is question 6 of the review: verbosity and info on one side, actions and
error/warning/fatal on the other. They never cross.

---

## Reporting

#### *What `$display` cannot do*

- A thousand operations per test, dozens of tests per regression: one `$display` per
  transaction and the log stops being readable before the first coffee
- And with `$display` the only way of lowering the noise is **deleting lines**, that is,
  losing exactly what you are going to need next time
- UVM replaces the `$display` with four macros that bring two things for free:
  context —time, component, file— and a **filter** that is driven from
  outside

Note:
The question that orders the slide, and it is worth throwing it at the group before the
answer: *what is wrong with `$display`?* The answer that always comes is "it is
ugly", and it is not that one. `$display` prints **or does not exist**: the decision of whether a
message comes out is taken at the moment of writing it, by editing the code.
What UVM adds is not format, it is that the decision moves to the moment of
**running**, and it is taken from outside with a plusarg. That change of moment is the whole
section: that is why the messages can be left in place, and that is why the log of a
regression and the log of a debug can come out of the same binary.
The piece of context, for whoever comes from VHDL or plain Verilog: none of this
is simulator magic. `` `uvm_info `` is a macro that assembles a string and hands it
to an object —the *report server*— that decides what to do. Everything that follows in
the section is configuring that object.

---

## Reporting

#### *The reporting macros*

- There are four and they differ by **severity**: `` `uvm_info ``,
  `` `uvm_warning ``, `` `uvm_error `` and `` `uvm_fatal ``. **All four** are counted
  in the *Report Summary*; what changes is the default **action** — `` `uvm_error ``
  comes with `UVM_DISPLAY|UVM_COUNT` and `` `uvm_fatal `` also kills the simulation
- The **ID** is the first argument: a string that says who is talking. It is what you filter
  with afterwards, so it is worth making it the name of the component and always the
  same one
- The **message** is the second, and it gets assembled with `$sformatf` when it carries data
- The **verbosity** is the third, and **only** `` `uvm_info `` has it: it is the one
  that decides whether the message comes out or not

{{code:code/u4/reporting/reporting.sv}}

Note:
The usual confusion: verbosity filters `` `uvm_info ``, and nothing else. The
warnings, errors and fatals have no verbosity — they are controlled with actions, which
is the last part of the section.

---

## Reporting

#### *The reporting macros: what each one does*

- This is how it looks in the scoreboard: a `` `uvm_error `` when the comparison fails, with
  the message assembled with `$sformatf`
- And this is how it comes out in the log. Look at what the line brings **without anybody asking
  for it**: the time, the file and the line, and the hierarchical path of the component that spoke

{{code:code/u4/reporting/tb_classes/scoreboard.svh#the-report}}

{{code:code/u4/reporting/tb_classes/scoreboard_error.txt}}

Note:
Worth stopping on the log line and reading it out loud from left to right,
field by field, because it is the one the student is going to look at a thousand times and nobody ever
explains it: severity, time, file and line of the `` `uvm_error ``, and then
`uvm_test_top.env_h.scoreboard_h` — the instance path. Only then comes the ID
and the message.
The pedagogical point is what is **not** in the code: the scoreboard did not print
the time or its own name. The macro put them in. That is the whole argument in
favour of never writing a `$display` in a testbench again.
And the honest comparison with the `$error` of day 2: that scoreboard also
made the test fail, but the context had to be written by hand — and there nobody
writes the hierarchical path, because they do not know it.

---

## Reporting

#### *The six levels, and why the message stays*

- The usual cycle: you fill the code with `$display`, you find the bug, you delete
  everything — and next week you write it again
- With verbosity the messages **stay in place** and do not get in the way. It is two steps,
  and the second one does not touch the code:
  - put a verbosity on each `` `uvm_info ``, according to how much noise it is
  - set the **ceiling** of the run: global, or per branch of the tree
- A message comes out if its verbosity is **less than or equal to** the ceiling. That is why
  `UVM_NONE` always comes out

{{code:code/u4/reporting/tb_classes/verbosidad.svh}}

Note:
The six levels, from least to most noisy: `UVM_NONE`, `UVM_LOW`, `UVM_MEDIUM`
—the default one—, `UVM_HIGH`, `UVM_FULL` and `UVM_DEBUG`. `UVM_FULL` is the one
nobody uses and the one that shows up in the enum on the slide, so it is worth
naming. A message gets printed if its
verbosity is **less than or equal to** the ceiling, so `UVM_NONE` always comes out.
The rule of thumb worth handing down, because otherwise everybody invents their own:
`UVM_LOW` for what you want to see in a regression —which test ran, how many
transactions—; `UVM_MEDIUM` for the summary of a component; `UVM_HIGH` for
every transaction that goes past. The monitors of the course are `UVM_HIGH` precisely for
that: in a normal run they are not seen, and when something fails they get switched on with a
plusarg.
The formal detail that gets copied wrong: the verbosity is the **third** argument of the
`` `uvm_info ``, and if you forget it, it does not compile. The ID —the first one— is a free
string, but do not pick it at random: it is the key you are going to filter with afterwards.
Make it the name of the component, in capitals, and always the same one.

---

## Reporting

#### *The global ceiling: a plusarg, without recompiling*

- It gets set in two ways, and the first one is the one used every day: a
  **plusarg** on the command line
- No code to touch and no recompiling. The same binary gives the log of the
  regression and the log of the debug
- The problem shows up with the team: if there are ten people with their own debug
  messages, raising the global ceiling brings you everybody's
- That is why it has to be possible to ask for it **per component**, which is the next slide

{{code:code/u4/reporting/tb_classes/verbosity_ceiling.txt}}

Note:
Worth running it live, because it is the cheapest demonstration of the section:
the same line above —`./obj_dir/top/sim +UVM_TESTNAME=random_test`— with and without
`+UVM_VERBOSITY=UVM_HIGH`, and the log goes from 7 `uvm_info` to 22. With `make` they are
6 and 21, because `run_sim` adds `+UVM_NO_RELNOTES` and that takes the banner away. Without recompiling anything — it is the same binary. They look
like few because this example sends **ten** operations on purpose, so the transcript fits
on the screen; with the thousand of the other sections the difference is three orders of
magnitude.
The detail that has to be said so that it does not surprise anybody later: the plusarg sets the
ceiling of the **whole tree**, from `uvm_top` down. There is no way of asking for
"high, but only the monitor" from the command line with this flag; for that
there is `+uvm_set_verbosity`, which is longer to type and almost nobody remembers.
The honest way out, and the one the next slide teaches, is setting it from the
code in the component you care about.
And the underlying argument, in case the group underrates it: this is the mechanism that
makes a regression log of a thousand tests readable. It is not classroom cosmetics.

---

## Reporting

#### *`uvm_cmdline_processor`: the command line, whole*

- `+UVM_VERBOSITY` and `+UVM_TESTNAME` are not read by magic: they are read by **a class**, and
  it is available for your own plusargs

```systemverilog
uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
string valor;

if (clp.get_arg_value("+COUNT=", valor)) count = valor.atoi();
```

- It is a **singleton**: `get_inst()` from any class, without building anything and
  without passing it through the `config_db`
- `get_arg_value` returns **how many times the argument appeared**, not the value:
  the value comes out through the `ref`. If it appeared twice you find out — `$value$plusargs`
  keeps quiet with the first one
- And there are `get_args()`, `get_plusargs()` and `get_uvm_args()`, which return the
  whole command line in a queue: it is how you print under what conditions
  a regression from three months ago ran

Note:
The course uses `$value$plusargs` and `$test$plusargs` in the `base_test` because they are
one line and they read themselves. Worth saying why in a production testbench
this class always shows up: `$value$plusargs` is a system task, so it cannot
be inherited, it cannot be substituted by the factory and it cannot be tested. The
`uvm_cmdline_processor` is an object, and that is enough for the three things.
The argument that pays off most is the last bullet and it is not the one you would expect:
`get_args()` printing the whole line in the `start_of_simulation_phase` is what
turns an old log into something reproducible. Without that, the log says what happened
but not what it was run with, and a regression from three months ago cannot be repeated.
The difference in the second bullet is worth an anecdote: two `+COUNT=` on the same
line —because the script adds them and the user does too— is a real case, and
`$value$plusargs` takes one without saying which. The `uvm_cmdline_processor` returns 2,
so at least you can notice. It is the kind of thing you pay for once and remember.

---

## Reporting

#### *The ceiling per branch: two methods and a tree*

- Every `uvm_component` comes with methods to set its own ceiling, in two flavours:
  only itself, or itself **and everything hanging below** (`_hier`)
- Careful about which hierarchy it is: it is **not** the DUT's module one. It is the tree that UVM
  assembles by calling `build_phase()` from the top down
- It is the same tree the prefix of each message comes out of, and the same one the
  `uvm_config_db` uses as a scope

![Instance hierarchy UVM builds in build_phase](res/diagrams/en/UVM-hierarchy.svg)
<!-- .element: class="grande" -->

Note:
This diagram is worth more than it looks, because it explains where that
very long prefix each message brings comes from: `uvm_test_top.env_h.scoreboard_h`. It is not
decoration — it is the **instance path** of the component that spoke.
And it is the same path the `uvm_config_db` uses for the scope. Worth saying it
explicitly: when in the tests we said "the scope is a hierarchical path", it was
literally this path. A single tree serves both purposes.
The clarification in the bullet is not a detail: this hierarchy **is not the DUT's**. A
scoreboard is not inside any module. It is the tree UVM assembles by calling
`build_phase` from the top down, and it exists only in the testbench.
Classroom trick: `uvm_top.print_topology()` prints this tree for real, written by
the library. It is the best way of showing that it is not a drawing.
`+UVM_CONFIG_DB_TRACE` is a different thing and it is better not to mix them: it does
not draw the tree, it traces every `set()` and every `get()` of the `config_db` with
the scope that was used — which is the knob for the other problem, the scope that
does not match.

---

## Reporting

#### *The ceiling per branch: where the call goes*

- The call goes **after** the hierarchy exists —otherwise the component
  is not there yet— and **before** the simulation starts
- That window has a name and it is one of the nine phases: `end_of_elaboration_phase`
- `set_report_verbosity_level_hier()` reaches the component **and its children**;
  `set_report_verbosity_level()`, only it

{{code:code/u4/reporting/tb_classes/env.svh#end_of_elaboration_phase}}

Note:
The window is what has to be left burned in, because the mistake gets made in both
directions. If the call goes in the `build_phase`, the component whose ceiling you want
to raise **does not exist yet** —its parent builds it further down— and the
call finds nobody. If it goes in the `run_phase`, the simulation has already started and
you missed the messages of the earlier phases.
`end_of_elaboration_phase` is exactly the gap between the two things: the whole
tree, and the time still at zero. It is the first time in the course that it gets
used for anything, and it is worth saying it that way — in the table of the nine
phases of day 3 it was not decoration.
The `_hier` suffix is the one that gets forgotten, and it fails silently: you set the ceiling of the
`env` without `_hier`, the `env` prints nothing anyway, and the monitor you
wanted to hear stays quiet. Rule of thumb: if you are aiming at a branch, `_hier`;
if you are aiming at a class, without.

---

## Reporting

#### *Switching off warnings, errors and fatal messages*

- A real situation: the DUT is fine, the scoreboard predicts the addition wrong, and the class
  is being fixed by somebody else. You need to carry on working in the meantime
- Lowering the verbosity ceiling **does not help**: it only affects `` `uvm_info ``, and what
  has to be silenced is a `` `uvm_error ``
- Another knob is needed

{{code:code/u4/reporting/scoreboard1.txt}}

Note:
The log on the slide is that of a scoreboard that adds wrong on purpose, and it is worth
looking at the *Report Summary* at the end before the error: `UVM_ERROR : 2`, one for each
`add_op` that came up in the ten operations of the example. That is the sum to do out loud:
with the thousand operations of the other sections it is **a hundred-odd errors**, one per
addition. That is the real problem the section comes to solve — not "the
message is annoying", but that **the log stops being any use for looking for something else**.
The question to throw at the group, because the wrong answer is the intuitive one:
*"I lower the verbosity ceiling and that is it?"*. No. A `` `uvm_error `` has no
verbosity; the ceiling does not touch it. It is the same distinction as the first slide, and
here it gets collected for the first time.
And the honest clarification before teaching how to switch off errors, because otherwise it
sounds odd: this is not so that the regression comes out green. It is to be able to work
half an afternoon while somebody else fixes their class, and it comes out the same day.

---

## Reporting

#### *Switching off messages: where it gets done*

- Warnings, errors and fatals are **immune** to the verbosity ceiling, and it is right
  that they should be: nobody wants to switch off an error by accident
- The knob that does reach them is called **actions**, and it answers another question:
  not *"does it get printed?"* but *"what gets done with this message?"*
- Printing is only one of the seven possible things

{{code:code/u4/reporting/tb_classes/UVM_report_actions.sv}}

Note:
The seven actions are a bitwise OR, not a list of mutually exclusive options: the
same message can be printed **and** written to a file **and** counted towards the
summary. That is why they combine with `|`.
`UVM_COUNT` is the one most often explained wrong, and it is worth saying it in full:
it is already switched on by default on every `` `uvm_error ``, and what it increments
is **a global counter** for the run, not one per ID. On its own it kills nothing,
because the default maximum is 0, which means "no limit". The one that cuts is
`+UVM_MAX_QUIT_COUNT=N` (`uvm_root.svh:1187`) —or `set_report_max_quit_count(N)`,
`uvm_report_object.svh:578`—, and
that one really is the answer to the four-gigabyte log when a scoreboard fails on
every transaction: you find out anyway, and in thirty seconds instead of in twenty
minutes.
`UVM_NO_ACTION` is the one the next slide uses to switch off the errors, and it has to be
said out loud what it is **not** for: it is not so that the regression comes out green.
It is to carry on working while somebody else fixes their class, and it comes out the same day.
A `UVM_NO_ACTION` that survives a commit is a bug waiting to happen.
And the pair worth naming: `set_report_severity_action` is by severity,
`set_report_id_action` is by that ID string you picked when writing the
message. That is where the discipline of having always used the same one gets paid back.

---

## Reporting

#### *Switching off messages: the complete example, and the log you are left with*

- `set_report_severity_action_hier(UVM_ERROR, UVM_NO_ACTION)` on the scoreboard:
  when an error shows up in there, do nothing
- It goes in the `end_of_elaboration_phase` of the `env`, for the same reason as the
  hierarchical verbosity
- And the log below is the result: same DUT, same broken scoreboard, zero
  errors in the *Report Summary*
- In `code/u4/reporting` the line is written and **commented out**: you uncomment it
  to reproduce this log, and comment it back. That it lives commented out in the repo
  is part of the lesson

{{code:code/u4/reporting/tb_classes/env.svh#end_of_elaboration_phase}}

{{code:code/u4/reporting/scoreboard2.txt}}

Note:
Say it out loud: switching off errors is for carrying on working while somebody else
fixes their class, not so that the regression comes out green.
And showing the *Report Summary* of the second log next to the first one is the best
warning the section gives: the testbench says **0 UVM_ERROR** and the DUT is still
exactly as broken as it was when we broke it. That is the reason a
`UVM_NO_ACTION` cannot survive a commit — it is a silent trap, and it is in
the appendix.
The scoreboard of this section adds too much ON PURPOSE, it is the bug we are
showing. That is why `code/u4/reporting/run.sh` exports UVM_ERRORS_OK=1: by
default a uvm_error makes the run fail, and here the error is the example.

---

## Reporting

#### *`uvm_report_catcher`: demoting the error you were expecting*

- `UVM_NO_ACTION` switches off **every** error of a branch. When the test
  verifies the error path on purpose —a `PSLVERR` that has to arrive— what
  has to be silenced is **one single one**, and the rest has to carry on shouting

```systemverilog
class demotar_pslverr extends uvm_report_catcher;
   virtual function action_e catch();
      if (get_severity() == UVM_ERROR && get_id() == "PSLVERR")
         set_severity(UVM_INFO);      // stops counting as an error
      return THROW;                   // and carries on, already downgraded
   endfunction
endclass

demotar_pslverr c = new();
uvm_report_cb::add(null, c);          // null = the whole testbench; or a component
```

- The catcher gets in **before** the report: it sees every message and can change its
  severity, its ID, its text or its action
- `THROW` lets it carry on already modified; `CAUGHT` makes it disappear
- And the difference that matters: the summary prints *Number of demoted UVM_ERROR
  reports : 1*. **The blackout leaves a trace**, which is what `UVM_NO_ACTION` does not do

Note:
It is the right answer to the previous slide, and the difference is one of honesty,
not of syntax. `UVM_NO_ACTION` on the scoreboard switches off the error and the log ends up
identical to that of a healthy testbench: nobody reading that log finds out. The catcher
downgrades **that** message, lets all the others through, and on top of that counts it on a
line of its own in the *UVM Report catcher Summary*. A reviewer who opens the log sees that there was an
error and that somebody decided it was fine.
When it really gets used: in the negative tests, which are half of a serious verification
plan. Writing to a read-only register has to give
`PSLVERR`; the test that proves it **expects** the error, and without a catcher that test
can never come out green. It is exactly the case of the capstone.
The implementation detail that surprises: a catcher is a `uvm_callback`, that
is, the same piece as the callbacks of day 6. That is why it gets registered with
`uvm_report_cb::add` and not with a `set_` of the component.
And the trap: if the catcher is too wide —by severity and nothing else— you have switched off
every error of the testbench with more ceremony than `UVM_NO_ACTION`. The
`get_id()` of the `if` is not optional.

---

## Reporting

#### *Summary of the unit*

- Two knobs, and they do not cross: **verbosity** filters `` `uvm_info ``; **actions**
  decides what gets done with warnings, errors and fatals
- Both can be set per component or per branch, in `end_of_elaboration_phase`
- And there is a third one for the **expected** error: the `uvm_report_catcher` demotes it
  and leaves it counted in the summary, instead of switching it off without a trace
- With that, debug messages get written once and stay in place for
  ever — which is the only thing that makes debug cheap
- And it arrives here, at the end of day 3, on purpose: it is the tool the
  exercises of days 4 and 5 get debugged with — the day 5 one is solved by
  **raising the verbosity**, and there is no other way of finding it

Note:
Close the day by going back to the 47 %: of everything seen today —tests, components,
phases, env— this is the section used **every day**, and the only one you
notice when it is missing. A testbench without reporting works just the same; debugging it costs
double.
The control question, which is also number 6 of the review: *"I lowered the verbosity
ceiling and the `` `uvm_error `` still shows up, why?"*. If the group
answers it without hesitating, the section closed.
And the warning for the day 5 exercise, worth giving now and not when they are
stuck: the bug is not visible in the default log. It is printed, at `UVM_HIGH`. Whoever
does not remember this section is going to read the code for half an hour before raising
the verbosity.
