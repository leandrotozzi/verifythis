<!-- es-sha: f62fd11aa032 -->
## Exercise · Day 4

#### *One more observer, without touching the ones already watching*

`cd code/ejercicios/d4 && bash run.sh`
<!-- .element: class="comando" -->

- A `uvm_subscriber #(command_s)` that counts the commands
- Instantiate it and connect it in the `env`, without touching the connections that are already there
- It is marked by cross-checking: your count has to come out the same as the `command_monitor`'s

Note:
The short exercise of the course: twenty minutes. What is being practised is not
writing the class —it is ten lines— but the `connect_phase`: if they forget the
connect, the class compiles, runs, and counts zero.
That is why the marking is done by cross-checking against the lines the
`command_monitor` prints: it is not enough for the number to exist, it has to
match what another component saw.
