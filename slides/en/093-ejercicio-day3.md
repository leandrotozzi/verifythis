<!-- es-sha: 5e56ebbad51e -->
## Exercise · Day 3

#### *A new test without touching the structure*

`cd code/ejercicios/d3 && bash run.sh`
<!-- .element: class="comando" -->

- Write `mult_tester` and `mult_test`, with `set_type_override`
- **Without touching `env.svh`**: the structure never finds out that the stimulus changed
- The `env` brings a `chequeo` component that marks the exercise on its own

Note:
Before turning them loose on the exercise, go back to the slide *"The map of day 3: what
replaces what"* of the object-based testbench and read the right-hand column straight through: the
`build_phase` of the env, the config_db, the `run_phase`, the objections and the
`set_type_override`. The five rows are crossed out, and the day closes there.
It is the day 2 exercise again, but with the factory. Worth having them
compare the two: on day 2 the type was picked in the code of the testbench, here
the factory picks it and the testbench does not change one line.
And have them look at the coverage at the end: with nothing but multiplications it drops to 26 %. A
focused test covers less, and that is the reason many are needed — and
the reason adding one has to be cheap.
