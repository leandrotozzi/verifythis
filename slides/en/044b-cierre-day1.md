<!-- es-sha: 4b2f35c78822 -->
## Six out of seven, again

#### *Closing the day*

- The regression that sent the bug to the fab said `PASS`. Today you have three
  ways of knowing whether that `PASS` was worth anything, and all three are
  columns of one table
- **What had to be tested?** A plan: one row per scenario, written before the
  testbench, from the spec
- **Who said it was right?** A scoreboard that predicts and compares — and that
  you watched fail with a bug inside
- **How much of the plan passed?** A `covergroup` with one bin per row, and the
  per-bin report, not the percentage
- The tester already asks for operations instead of moving wires: that was the
  BFM. What you still cannot do is **change the stimulus without editing the
  file**. Tomorrow is that

Note:
Thirty seconds, and they are the ones that close the arc of the day: the first
slide asked a question and this one answers it with what the student wrote,
not with theory. If the group is tired, put the 14 % slide back up for a second
before this one: the question was *"how do you know you verified?"*, and the
short answer is *"I have the plan, I watched it fail and I know which bin is
missing"*.
What not to over-promise: this does not prevent the respin. What it prevents
is sending to the fab a `PASS` nobody knew the meaning of.
The last bullet is the one day 2 opens with *"Yesterday we left…"*: a tester
that only multiplies is copying the file and deleting five lines. That is the
problem classes solve, and it is worth leaving as a problem and not as a
promise.
