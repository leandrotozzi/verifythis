<!-- es-sha: 4202b96312eb -->
## Exercise · Day 6 · 3 of 3

#### *Three planted bugs, and none of them looks like the others*

`cd code/ejercicios/d6-debug && bash run.sh`
<!-- .element: class="comando" -->

| | File | How it shows up |
|:--:|---|---|
| **1** | `driver.svh` | **it hangs**: it dies on `[PH_TIMEOUT]` |
| **2** | `default_seq_test.svh` | **it ends at `t=0`** and says PASS |
| **3** | `random_sequence.svh` | **it lies in green**: `add_test` passes with the wrong stimulus |

- The checker says **which** of the three is still broken. Which line it is, is
  the exercise

Note:
It is the only exercise of the course where there is nothing to write: there is
something to find. And it is the one that looks most like your first month on the
job, where nobody hands you a file with a hole — they hand you a testbench that
does not work.
The idea that orders the three rows, and worth saying before letting them go:
**the failure modes of a UVM testbench do not look like each other**. The one
that hangs shows up at once and costs nothing. The other two pass **in green**,
and those are the ones that cost weeks.
All three are in the debug appendix table, and reading it is allowed: the list
exists precisely so that the second time it takes them five minutes.
The third one deserves its own comment because it breaks the reflex the course
has been training: `+TOPOLOGY` is the right tool for *"the tree is not the one
you drew"*… and here it **is not enough**, because what got built wrong is a
`uvm_object` and the tree only shows `uvm_component`. The only way to see it is
to look at what went out on the bus.
