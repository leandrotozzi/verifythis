<!-- es-sha: d087cdd436fe -->
## Exercise · Day 8 · 2 of 2

#### *The reference model in C, and the two mutations that prove it*

`cd code/ejercicios/d8-dpi && bash run.sh`
<!-- .element: class="comando" -->

- The only file of the exercise is `vtalu_golden.c`. Not one line of the
  testbench gets touched
- Two operations are missing: the **subtraction with its borrow** —which goes out
  through a pointer— and the product with the mutation hook
- The checker runs three times: healthy DUT against your model, **mutated DUT**
  (`VTALU_BUG=1`), and your mutated model (`+GOLDEN_BUG`)

Note:
Stage 2 is what makes the exercise worth it, and it is worth explaining first:
against the healthy DUT, a model returning some fixed thing could pass by
accident if the stimulus were poor. With the DUT lying on bit 0, there is no way
of passing without having computed — it is the same mutation test as the
capstone, pointed at the model instead of at the scoreboard.
The subtraction is the one that trips people, and not because of the arithmetic:
`a - b` is one line. What gets forgotten is the **second half of the answer**,
the borrow, and it gets forgotten because it crosses the boundary in another way
—through a pointer, which is how a SystemVerilog `output int` travels—. The
scoreboard compares it, so without it every subtraction fails and no other
operation does: that pattern of failures is the one to learn to read.
And the trap you cannot see, which is solved in the skeleton on purpose so they
do not lose the hour there: without `extern "C"`, Verilator hands the file to the
**C++** compiler, the symbol comes out mangled, and the link fails with an
*undefined reference* to a function written two lines above. It is DPI's number
one failure mode with Verilator.
