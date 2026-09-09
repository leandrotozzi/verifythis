<!-- es-sha: 42c12a76b98e -->
## Trends

#### *First silicon almost never comes out right*

![Percentage of projects reaching first silicon with no bugs, by year](res/trends/resultado.svg)
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

![Growth in the number of blocks and embedded processors per chip](res/trends/complejidad.svg)
<!-- .element: class="grande" -->

---

## Trends

#### *Verification is not a stage, it is half the work*

![How the verifier's time is split: almost half of it goes into debug](res/trends/esfuerzo.svg)
<!-- .element: class="grande" -->

Note:
Here is the argument for why this course exists: the verification effort has
already caught up with design. Verifying is not the final step before tape-out: it is
half the project, with its own team and its own language.

---

## Trends

#### *And it is verified, mostly, with UVM*

![Adoption of verification methodologies: UVM against the rest](res/trends/metodologia.svg)
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
