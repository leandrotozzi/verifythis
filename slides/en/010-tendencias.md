<!-- es-sha: 4198c1f13da0 -->
## Trends

#### *Why they come back: what is inside a chip today*

![What is inside 2024 IC/ASICs: asynchronous clocks, embedded processor, security, AI, RISC-V and safety](res/trends/en/complejidad.svg)
<!-- .element: class="grande" -->

Note:
It is the first half of the answer to *why they come back*: inside there are
two asynchronous clocks in almost all of them, a processor in five out of six
and an AI accelerator in more than half. It is not that verification is done
worse than twenty years ago; it is that there is much more to verify, and the
question on the first slide is harder to answer than ever.

---

## Trends

#### *Verification is not a stage, it is half the work*

![49 % of the designer's time goes to verification; 47 % of the verification engineer's time goes to debug](res/trends/en/esfuerzo.svg)
<!-- .element: class="grande" -->

Note:
Here is the argument for why this course exists: the verification effort has
already caught up with design. Verifying is not the final step before tape-out: it is
half the project, with its own team and its own language.
The lower 47 % is planted today and collected twice: in the second
exercise this afternoon, when the log says `FAILED` and nothing else, and in
the reporting section on day 3, which is where the log learns to say why.

---

## Trends

#### *And it is verified, mostly, with UVM*

![What verification uses in 2024: UVM at 80 % in IC/ASIC and 50 % in FPGA](res/trends/en/metodologia.svg)
<!-- .element: class="grande" -->

Note:
This one answers *with what*: eight out of ten ASIC projects verify with UVM,
and half of the FPGA ones. What follows —the COBOL joke and the introduction—
is what that UVM is and why it is not scary. And one thing worth leaving said
now: UVM does not answer the question on the first slide. The testbench does;
UVM is the way to write it so that the person next to you recognizes it.

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
And it is the bridge to the next section: eight out of ten verify with UVM, UVM
is written in this language, and on days 1 and 2 everything UVM will later hand
you ready-made gets written by hand. Thirty keywords are enough.
