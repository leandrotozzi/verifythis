<!-- es-sha: 870dd17d9d22 -->
## Exercise · Day 4 · 2 of 2

#### *The `#500` is a patch*

`cd code/ejercicios/d4b && bash run.sh`
<!-- .element: class="comando" -->

- The *put and get* testbench with **one line changed**: the `env`'s FIFO comes
  unbounded
- The tester empties its thousand commands at `t = 0`, waits the usual `#500`,
  drops the objection — and the simulation ends **in green with 13 commands on
  the bus**
- It gets fixed in the driver: an objection **while there is a command in flight**
- `env.svh` does not get touched: the unbounded FIFO is the DUT of this exercise

Note:
It is the exercise that puts hands on the two things the section claims and does
not demonstrate: that `put()` blocks, and that the tester's `#500` is a patch.
The number is measured and is worth saying: with the size-1 FIFO the testbench
sends the thousand operations; with the unbounded FIFO, **13**. Nobody touched
the DUT, nobody touched the stimulus, and the difference is a constructor's
default argument.
What the back-pressure was doing without anybody having designed it that way:
keeping the tester in step with the bus. Take it away and the tester is left
talking to itself.
The fix has to be discussed, because the obvious answer —raise the `#500`— is the
one to reject. The question that orders it: **who knows when the bus is done?**
Not the tester, which knows when it is done *putting*. It is the driver, which is
the one driving. That is why the objection goes there, and that is why it is the
pattern of any real UVM driver.
And the detail that decides whether the exercise works, which is also from the
field: the `raise`/`drop` pair goes **after** the `get()`, not around it. Around
it, the driver holds an objection waiting for work that is never coming, and the
test never ends — which is the other failure mode of the debug appendix table.
