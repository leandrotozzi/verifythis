<!-- es-sha: dbd1ef9ec078 -->
## Trends

#### *First silicon almost never comes out right*

![How IC/ASIC projects end in 2024: 14 % get first silicon right and 75 % run late](res/trends/en/resultado.svg)
<!-- .element: class="grande" -->

Note:
The number is from the Wilson Research Group 2024, it is not an impression: only 14 %
of projects come out right on first silicon, which means six out of every seven
need at least one respin. And it is the worst figure in twenty years of the survey.
Asking who has done a tape-out and how it went hooks people better than the chart.
If they ask where the data comes from: `res/trends/data.json`, and the figures are
regenerated with `make figs`.

---

## Trends

#### *Why: what is inside a chip today*

![What is inside 2024 IC/ASICs: asynchronous clocks, embedded processor, security, AI, RISC-V and safety](res/trends/en/complejidad.svg)
<!-- .element: class="grande" -->

---

## Trends

#### *Verification is not a stage, it is half the work*

![49 % of the designer's time goes to verification; 47 % of the verification engineer's time goes to debug](res/trends/en/esfuerzo.svg)
<!-- .element: class="grande" -->

Note:
Here is the argument for why this course exists: the verification effort has
already caught up with design. Verifying is not the final step before tape-out: it is
half the project, with its own team and its own language.

---

## Trends

#### *And it is verified, mostly, with UVM*

![What verification uses in 2024: UVM at 80 % in IC/ASIC and 50 % in FPGA](res/trends/en/metodologia.svg)
<!-- .element: class="grande" -->

---

## Is SystemVerilog the *COBOL* of electronics?

| Language | Reserved Keywords |
| --- | --- |
| ANSI COBOL 85 | 357 |
| SystemVerilog | 248 |
| VHDL 2008 | 115 |
| Verilog 95 | 102 |
| C# | 102 |
| C++ 20 | 92 |
| Python 3 | 35 |

> *"* No academic computer scientists participated in the design of COBOL;
>  all of those on the committee came from commerce or government"* Sound familiar?

Note:
It is a joke with a moral: SystemVerilog has 248 keywords —the ones in Annex B
of IEEE 1800-2017— and nobody uses them all. In this course we are going to use about
thirty. The same thing happens with UVM: the library is enormous and with six or seven
classes you put together a complete testbench.
It is useful for lowering the anxiety of whoever arrives scared by the size of UVM.
