<!-- es-sha: fb322a53c041 -->
## The VTALU spec

![VTALU waveform: start, done and the result](res/diagrams/en/wave-dut.svg)
<!-- .element: class="grande" -->

- *start* has to stay at 1 and the operands stable until  
  the operation finishes
- *done* goes up when the operation finishes: on the multiplication  
  it is a one-cycle pulse; on add/sub/and/xor it is a **level**, and it stays  
  up while *start* stays up
- *reset_n* is asynchronous and active low; the diagram starts with the DUT  
  already out of reset
- *ovf* comes out together with *done*, and it is the **borrow of the subtraction**: it is 1  
  when `A < B`. For the other operations it is always 0

Note:
The protocol is everything you have to respect: start up and operands stable
until done. Careful with the fine print: done is a pulse on the multiplication (it
turns itself off) and a level on add/sub/and/xor, where it is `start && (op != no_op)`. It is
the kind of detail that only shows up when the testbench hangs and nobody
knows why.

---

## The VTALU spec

| Operation | Opcode | Cycles | `ovf` |
| --- | --- | :--: | --- |
| no_op | 3'b000 | — | 0 |
| add_op | 3'b001 | 1 | 0 |
| sub_op | 3'b010 | 1 | **`A < B`** |
| and_op | 3'b011 | 1 | 0 |
| xor_op | 3'b100 | 1 | 0 |
| mul_op | 3'b101 | 4 | 0 |
| *free* | 3'b110 | 1 | 0 |
| rst_op | 3'b111 | — | — |

- **Cycles** counts `clk` edges with `start` up, up to and including the one
  that raises `done`: one on the single-cycle ops, four on the multiplication.
  The plan and the day 7 assertions count the same way
- `rst_op` is not decoded by the RTL — the DUT sees it as *unused*.
  It is the testbench convention for pulsing `reset_n`, and that is why it
  is in the `operation_t` of the testbench
- **`3'b110` is free on purpose**: it is today's exercise

Note:
rst_op belongs to the testbench, not to the RTL: the DUT sees 3'b111 as unused. It is in the
enum because the tester asks for the reset as if it were one more operation, and that way the
reset enters the functional coverage. A good moment to preview that the coverage
plan includes "any operation after a reset".
The ovf column is the one that gets the most discussion, and that is good: with 8-bit
operands and a 16-bit result, neither the addition nor the multiplication can overflow — the
subtraction can, and only when A < B. Which means there is an output of the DUT that for five
of the six operations is always 0. Ask out loud: how do you verify
a signal that almost never moves? The answer is tomorrow's, and it is a bin.
And the free opcode: 3'b110 is not there by chance and not by oversight. It is
this afternoon's exercise, and it is worth saying now so that nobody reads it as a
design slip.

---

## The VTALU spec

#### *Single Cycle: Add - Sub - AND - XOR*

{{code:code/vtalu_dut/vtalu_1c.sv#the-two-resets}}

- Two `always_ff` and nothing else: one registers `A op B`, the other raises `done`
- The resets **are not the same**: the one on the result is **synchronous** —only `clk` in
  the sensitivity list—, the one on `done` is **asynchronous**
- `done <= start && (op != no_op)`: that is why on these four operations `done` is
  a **level** and stays up while `start` is

Note:
The asymmetry of the two resets is not an oversight: it comes from the original VHDL and is
copied as is on purpose. It is exactly the kind of detail a testbench
has to expose, and that is why the DUT was not "cleaned up" when it was translated.
That `done` is a level here and a pulse on the multiplication is the fine print that
is going to hang the first testbench of the course. It is worth going back to the waveform
of the first slide and pointing at it again.
The `default: ;` of the case is what makes `no_op` and the unused opcodes not
change the result: the ALU keeps whatever it computed last.

---

## The VTALU spec

#### *Multi Cycle: Multiplication*

{{code:code/vtalu_dut/vtalu_mult.sv#the-pipeline}}

- It is a pipeline: the operands get registered, they get multiplied, and the product
  goes through two more registers before coming out on `result_mult`: four edges
- The `done` travels down **the same chain** —`done3`, `done2`, `done1`— so it
  arrives exactly with the data and not before
- The `& ~done_mult` of each stage is what turns the chain off on its own: that is why here
  `done` is a **one-cycle pulse**, even if `start` stays up

Note:
The four-edge latency is on purpose, and it is the reason the conventional testbench exists:
it forces the testbench to **wait for `done`** instead of reading the result on the next
cycle. A combinational DUT would teach nothing.
The `& ~done_mult` is subtle and worth reading slowly: without it, while `start`
was up the chain would reload itself and `done` would stay at 1. It is
copied from the original VHDL as is.
The question that orders the slide: what happens if the testbench sends a
multiplication and reads the result on the next cycle? It reads the previous result,
and the scoreboard reports an error that is not in the DUT.

---

## The VTALU spec

#### *Top Level*

{{code:code/vtalu_dut/vtalu.sv#the-mux}}

- The top computes nothing: it instantiates the two blocks and **decodes** the opcode
- `es_mult = (op == mul_op)`. The `start` is routed to only one of them, and `result`,
  `done` and `ovf` come out of the same side
- That is why the bus protocol is a single one even though inside there are two different
  latencies: what the testbench sees is `start` → `done`

Note:
That both blocks share `A`, `B` and `clk` and only split on the `start`
is what makes the DUT have a single interface. Worth pointing out because it is the
shape the `vtalu_bfm` of interfaces and BFM is going to have.
The complete file, with both instances and their connections, is in
`code/vtalu_dut/vtalu.sv`. Here there are only the decode and the four lines that decide.
Worth pointing out why it is a decode and not a loose bit: with an `op[2]` the
opcodes would have to sit in tidy halves of the space, and the design
would lose the freedom to assign them as convenient. A decode costs one gate
and does not tie the spec down. And along the way, the free opcode 3'b110 falls on the
single-cycle side without anybody having to do anything. The DUT does not validate the
opcode; the one that has to catch it is the verification plan.

---

## The VTALU spec

#### *How to run it*

- The DUT lives in `code/vtalu_dut/`, in **SystemVerilog**
- The simulator of the course is **Verilator** (free, no licence):

```sh
make u4/tests          # one UVM example:  ~1 min 30 the first time
make u4/tests          # the second, with ccache:      ~15 seconds
make               # the 38 examples
```

- The ones that use UVM compile **the whole library** the first time. Install
  `ccache` before starting: the course detects it on its own and does not recompile twice
- Every example has its `run.sh`; the common flags are in
  `code/verilator/common.sh`

Note:
Here it is worth leaving the deck and running it live. The numbers on the slide are
measured on a 12-core laptop. On a 2-core machine —a free Codespaces— the
first one is 4 minutes; the second is still 15 seconds, because a ccache hit
is copying a file and that does not depend on how many cores you have. Which means
the expensive part is paid **once**.
What has to be explained is where the difference between 1 min 30 and 15
seconds comes from, because it is not magic: Verilator compiles every simulation to a native
binary, and for that it generates about 2300 C++ files —almost all of them from the UVM library—.
`ccache` stores the result of each one; the second time it does not compile again,
it copies. It is in the Dockerfile and in the devcontainer, and outside it is enough to have it
installed.
And the one to stress anyway: Verilator is free — the student takes it
home and keeps practising without asking anybody for a licence.

---

## The VTALU spec

#### *Looking at the real waves*

- The diagram on the first slide is **drawn**. The real one you generate yourself,
  and it is the tool 47 % of the work gets done with: debugging

```sh
cd code/u2/convencional
VLT_TRACE=1 bash run.sh      # compiles with --trace and dumps vtalu.vcd
gtkwave vtalu.vcd            # or surfer, or whatever viewer you use
```

- `VLT_TRACE=1` turns on two things at once: Verilator's `--trace` and the top's
  `$dumpfile`/`$dumpvars`, which without the flag would not compile
- It costs nothing and it is free, same as the simulator. When the testbench hangs
  on `while (done == 0)`, this is what is going to tell you why

Note:
It is worth opening it live once, even for thirty seconds: load
`op_set`, `start` and `done`, and show the one-cycle pulse of the multiplication
next to the level of the single-cycle ones. It is the fine print of the protocol of
slide 1, but seen.
And say it explicitly: whoever takes the course alone has their safety net here.
When an exercise does not work out, the answer is almost always in the waves before
it is in the code.

---

## The VTALU spec

#### *Summary of the unit*

- The **protocol** is a single sentence, and it has to be respected: `start` at 1 and the
  operands stable **until `done` goes up**
- The fine print that is going to hang the first testbench: `done` is a one-cycle
  **pulse** on the multiplication and a **level** on the single-cycle ones
- Inside there are **two blocks** with different latencies —one and four cycles— and the
  top **decodes** the opcode. Outside, the bus is a single one
- `ovf` is one more output, and it belongs to `sub_op` and to nobody else
- `rst_op` **does not exist for the RTL**: it is a testbench convention for
  pulsing `reset_n`, and that is why it enters the coverage
- The DUT does not validate the opcode: the free one **raises `done` all the same**,
  with the `result` of the previous operation. Catching it is the **verification
  plan's** job, not the design's
- And the tool used 47 % of the time is already installed:
  `VLT_TRACE=1` and GTKWave

Note:
Closing of the section that looks like RTL and is really about verification. The
question to close with: which of these seven facts is the most expensive one to
forget? The one about `done`, and it will show today, in the waves exercise.
Worth saying why the DUT was not "cleaned up" when it was translated from VHDL: the
asymmetry of the resets and the unvalidated opcode are **exactly** the kind of
thing a testbench has to expose. A tidy DUT teaches nothing.
