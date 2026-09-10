<!-- es-sha: 42b61a50657d -->
<!-- .slide: id="referencias" -->

## References

- **IEEE 1800-2017** — SystemVerilog Language Reference Manual. The final arbiter
  of every discussion about syntax.
- **IEEE 1800.2** / **Accellera UVM** — the methodology, and the *UVM User Guide*.
  You have the code of `uvm-core` on disk: `make uvm`.
- **Verification Academy** — Siemens EDA ·
  [verificationacademy.com](https://verificationacademy.com)
- **Salemi, Ray.** *The UVM Primer* — Boston Light Press, 2013. The book I
  learned UVM with, and where several of the examples in `code/` came from.
- **2024 Siemens EDA / Wilson Research Group Functional Verification Study**.
  Source of the **data** of Trends. The charts are our own: they are generated
  with `make figs` from `res/trends/data.json`.
- **On RAL**: the *Register Layer* chapter of the **UVM 1.2 User Guide** from
  Accellera is the long explanation, and the table of the twenty-five field
  accesses —`RW`, `WOC`, `W1C`…— is in the **IEEE 1800.2**, under `uvm_reg_field`. What
  the unit does not use lives in the same place: `add_hdl_path` for the backdoor,
  and **IP-XACT** (IEEE 1685) or **SystemRDL** (Accellera) to generate the model instead
  of writing it.
- **On clocking blocks**, which is the liveliest discussion of the course: the
  threads by **Dave Rich** on Verification Academy (2014, 2022 and 2024), his paper
  *The Missing Link: The Testbench to DUT Connection*, and the **DV Coding Style
  Guide from lowRISC/OpenTitan**, which makes them mandatory. The summary, with the
  links and the quotes, in **`docs/clocking-blocks.md`** (in Spanish).

Note:
The list is ordered by when you are going to need it, and it is worth saying so.
The LRM and the *User Guide* are for consulting: nobody reads them straight through, you go and
look things up when there is a discussion about syntax or semantics. The Verification
Academy is the place where almost everything this course left out lives, and it is
free with registration.
About Salemi's book it is worth repeating what `docs/en-que-se-diferencia.md` (in Spanish) says: this
course does not replace it and does not follow it. If somebody wants a second pass over
the same concepts written by another person, it is the best one there is to start with.
And the point about the charts, because it is the part a student may want to
verify: the percentages of unit 1 are from the Wilson Research
Group study; the charts are our own and get regenerated with `make figs` from a JSON that
is in the repo. Nothing in unit 1 is an image downloaded from the internet.

---

<!-- .slide: id="el-libro" -->

## If you want to keep reading

<div class="creditos creditos-ref">
<a class="libro" href="https://www.amazon.com/UVM-Primer-Step-Step-Introduction/dp/0974164933" target="_blank" rel="noopener">
<span class="libro-tapa" aria-hidden="true"></span>
<span class="libro-txt">
<span class="libro-kicker">The book I learned with</span>
<span class="libro-titulo">The UVM Primer</span>
<span class="libro-pie">Ray Salemi &middot; Boston Light Press, 2013 &middot; ISBN 978-0974164939</span>
</span>
</a>
<p class="libro-nota">This course is not that book: it has another structure, another DUT, another simulator and four units of material the book does not cover. What it does share is credited in <code>NOTICE</code>, and the complete list of differences is in <code>docs/en-que-se-diferencia.md</code> (in Spanish).</p>
</div>

Note:

It is worth saying out loud when you get here: the book is short, it is well
written and it is still the best way to start in English. If the course was of any
use to somebody, let them buy it.

---

## Credits

- Part of the examples in `code/` derives from those of the **UVM Primer**, published
  by its author under **Apache-2.0**. Here they stay under Apache-2.0, with the `NOTICE`
  the licence asks for and the list of changes.
- The course —`slides/` and `docs/`— is **CC BY 4.0**. The tools in `tools/`,
  **MIT**.
- The trend charts are our own, made from the published percentages
  of the Wilson Research Group / Siemens EDA study.
- **reveal.js** and **forkit.js** by Hakim El Hattab (MIT); the typefaces
  Chakra Petch and IBM Plex under SIL OFL 1.1.

Note:
This slide is not legal formalism, and it is worth saying why it is here: the course asks
to be cited, so it has to cite first. What was borrowed is
named, with its licence and with the list of changes in the `NOTICE`.
The practical part for whoever wants to reuse the material: **CC BY 4.0** the slides and the
docs, **Apache-2.0** the code, **MIT** the tools. It can be taught,
adapted, translated and charged for. The only condition is citing the source, and there is no
hidden "non-commercial" clause.
If somebody asks why three licences instead of one: because they are three different
things. The code derives from Apache-2.0 code and has to go on being that; the
slides are original work and CC BY is the one an academic setting understands; the
tools are software and MIT is what anybody copying them expects.
