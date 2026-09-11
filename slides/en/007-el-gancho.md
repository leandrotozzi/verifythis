<!-- es-sha: 30b1f1d7713d -->
## Six out of seven

#### *And the bug that reached silicon passed a green regression*

![How IC/ASIC projects end in 2024: 14 % get first silicon right and 75 % run late](res/trends/en/resultado.svg)
<!-- .element: class="grande" -->

- **14 %** of projects get first silicon right. Six out of seven go back to
  the fab, and it is the worst figure in twenty years of the survey
- Every functional bug that reached silicon went through a testbench first.
  That testbench ran, finished, and **said everything was fine**
- Nobody tapes out with a `FAILED` in the log. You tape out with a `PASS`
- Today has a single question: **how do you know you verified?** And *"I ran
  a lot of tests"* is not an answer

Note:
It is the first slide of the course on purpose: before the word UVM and before
any other chart, a question the student cannot answer yet. The number is from
the Wilson Research Group 2024 survey and it is not an impression: only 14 %
come out right on first silicon, so six out of seven need at least one respin,
and it is the worst figure in twenty years of the survey. Asking who has done a
tape-out and how it went hooks better than the chart. If they ask where the
data comes from: `res/trends/data.json`, and the figures are regenerated with
`make figs`.
The honesty worth saying out loud: not every respin is functional —there are
timing ones, analog ones, a spec that changed late—. But the one that is went
through a regression that said `PASS`, because had it said `FAILED` it would
not have been fabricated. That is the enemy of the day, and it is not the
verification engineer nor their testbench: it is a `PASS` nobody knew the
meaning of.
The question in the last bullet is thrown to the group and **not** answered.
The answers that will come are *"100 % coverage"*, *"I ran a thousand
operations"* and *"nothing failed"*, and all three come back today: the first
is the coverage section, the second is the plan, and the third is the one that
hurts most, because *nothing failed* is exactly what the respin's regression
said. The short answer arrives in the conventional testbench, when we put a bug
into the DUT on purpose; the long one is the whole day, and the last slide of
the day comes back to this question with what the student wrote.
