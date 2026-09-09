<!-- es-sha: 95c0ec3c3c89 -->
## Callbacks

#### *The third hook*

- On day 1 we promised **three** ways of writing a new test without touching the env:
  **constraints**, **factory override** and **callbacks**. Two are done
- The three are the same idea at different heights: the constraint changes **values**,
  the override changes **a whole class**, the callback changes **what a class
  does at one point**
- The case that separates them: you are handed a VIP agent —from another team, or bought— and
  you need the driver to send a broken piece of data **once in a while**
- With an override you have to rewrite the whole driver to change one line. With
  a callback you hook that line and nothing else
- And there is a difference that is not a matter of style: **callbacks stack**. The
  override picks *one* class; the callbacks all run, **every one of them**, in order

Note:
This half section exists because unit 1 promises three hooks, and without it the
course delivers two. Fifteen minutes are enough: the mechanics are small and what has to be
left behind is the criterion for when it gets used.
The criterion, said in one line: **override when the what changes, callback
when the when changes**. If the new class differs from the old one in several
methods, it is an override. If it is the same class with an addition at one point, it is a
callback — and above all if the original class is not yours and you cannot touch it.
The key word in all of this is **VIP**. In a real project half of the
agents come from outside, with their licence and their support, and editing them is not an
option: the next version wipes your change. The callback is the extension
point the one who wrote the VIP left on purpose.
And that they stack is what makes it possible for two engineers to hook different
things into the same driver without stepping on each other. With overrides, the second one wins.

---

## Callbacks

#### *The hook: one class, one empty virtual method*

{{code:code/u7/callbacks/tb_classes/driver_callback.svh#driver_callback}}

- A `uvm_callback` **is not a component**: it is not in the tree, it has no phases and
  it does not show up in `print_topology()` — just like a sequence
- The base method is **empty on purpose**: with nobody registered, the testbench
  runs exactly as before
- It is a `task` and not a `function` because a *delay* callback has to be able
  to consume time. One that only edits the transaction could be a function

Note:
It is worth stopping on the fact that it is a normal class, extending `uvm_callback`, which
extends `uvm_object`. There is no magic: the only thing `uvm_callback` does is give it
a place in the pool UVM keeps per component instance.
The `typedef class driver;` at the top of the file is the boring and
necessary part: the callback receives the driver, and the driver registers the callback, so
one of the two has to be forward-declared. In a real testbench
this lives in its own file for that very reason.
If somebody asks why the base method is empty instead of abstract:
because `uvm_do_callbacks` walks **the whole queue**, and an empty queue has to
be legal. The empty base class is what makes "no callbacks" the normal case
and not an exception.

---

## Callbacks

#### *Two lines in the driver, and not one more*

{{code:code/u7/callbacks/tb_classes/driver.svh#register-cb}}

{{code:code/u7/callbacks/tb_classes/driver.svh#run_phase}}

- `` `uvm_register_cb `` declares the type/callback pair. Without it the `add()`
  hooks up all the same and the callback **runs** — with a `UVM_WARNING CBUNREG`
  lost in the log, and without the type check or `add_by_name`
- `` `uvm_do_callbacks `` is the extension point: it walks the queue of **that
  instance** of driver, in order

Note:
The diff against the driver of the Agents section is exactly two lines, and
it is worth showing it with a live `diff`: `diff code/u7/agents/tb_classes/driver.svh
code/u7/callbacks/tb_classes/driver.svh`. Everything else —the `get_next_item`, the
`send_op`, the `item_done`— is the same.
The failure mode of the missing `uvm_register_cb` is not the one you expect, and it
is worth telling it with the source in hand because half the tutorials get it
backwards: `uvm_callback.svh:744` reports a `UVM_WARNING CBUNREG` and **carries
on** — the `add()` puts the callback into `m_base_inst.m_pool` all the same
(`:777-783`), and `` `uvm_do_callbacks `` reads that pool without consulting the
registry (`:964-1006`). Which means: without the macro the callback runs, and what
you lose is the type check and `add_by_name` by derived type. That is worse than an
error: it is a warning among a thousand lines, and the testbench ends up outside
the contract without anyone noticing.
That is why the `run.sh` of the example does not check the macro but the effect: it
counts how many times the callback ran and fails if it is zero. An example that
"passes" without having injected anything proves nothing, whatever the reason it
came unhooked.
Where to put the `` `uvm_do_callbacks `` is the real design decision, and it is the
same one taken by whoever writes a VIP: every hook point is a promise of
forward compatibility. That is why VIPs have three or four, not thirty.

---

## Callbacks

#### *Putting them in: the test, and nothing but the test*

{{code:code/u7/callbacks/tb_classes/inject_test.svh#hooking-the-cb}}

- The test **does not touch** the env, nor the agent, nor the driver, nor the sequence. Just
  like the override, one level further down
- `end_of_elaboration_phase` and not `build_phase`: the driver is a grandchild of the env, and
  when the `build_phase` of the test finishes **it does not exist yet**
- The two callbacks go on the **same** instance and **both** run, in the
  order in which they were added

`bash run.sh +CALLBACK_TRACE` prints the queue of the driver
<!-- .element: class="comando" -->

Note:
The phase trap is the one that takes somebody's whole afternoon: `uvm_callbacks::add`
needs the handle of the component, and the tree is built top
down. In the `build_phase` of the test, `env_h` exists —it has just created it— but
`env_h.clase_agent_h` is `null`. `end_of_elaboration_phase` runs with the whole tree
assembled, which is exactly what is needed.
The alternative that is sometimes seen is `add_by_name("*driver_h", cb, this)`, with a
pattern instead of a handle. It is useful when you do not want to go across the hierarchy, and
it has the same phase problem.
And the passive agent does not show up in either of the two lines for a reason that is obvious
once said: it has no driver. Callbacks hang off instances, not off
types, so "the driver of the active agent" is a concrete address in the
tree.

---

## Callbacks

#### *The flipped bit the scoreboard does not see*

`cd code/u7/callbacks && bash run.sh`
<!-- .element: class="comando" -->

- The `flip_bit_cb` flips a bit of `A` in one out of every eight transactions. The
  scoreboard **says nothing**, and both runs close at 0 `UVM_ERROR`
- It is not a hole in the checker: it is the proof that **the monitor watches the
  wire**, not what the driver thought it was going to send
- A monitor that rebuilt the transaction from the driver —or that copied it
  from the sequencer— would have given *PASS* on data the DUT never saw
- What can be seen of the `jitter_cb` is the **time**: same stimulus, more cycles

| The hook | Changes | How many at a time |
| --- | --- | :--: |
| **Constraint** | the values | as many as you like |
| **Factory override** | the whole class | **one** |
| **Callback** | what a class does at one point | as many as you like |

Note:
This is the slide of the half section, and the exercise of thinking is worth more than the
code: *"if I inject an error and the scoreboard does not scream, is the scoreboard wrong?"*
Let the group argue about it for a minute before answering.
The answer is no, and it is one of the most important things in the course: the
scoreboard predicts from what the **monitor** saw on the bus. If the driver
sends `A^1`, the DUT computes with `A^1`, the monitor sees `A^1` and the prediction gives
`A^1`. All consistent. The only testbench this callback would break is
one with a monitor that does not watch the signals — and that testbench was wrong before
the callback ever existed.
Out of that comes the rule we already saw in Agents and that now has a demonstration:
**the monitor watches the wire, always**. An injection callback is, besides a
tool, the cheapest test there is for finding out whether your monitor does it.
To inject an error the scoreboard **does** have to catch, you have to break
the DUT, not the stimulus — which is exactly what the `+BUG=1` of the capstone does.
