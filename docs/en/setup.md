<!-- es-sha: 48824877b8b7 -->
# Setting up and running the examples

The four ways to get the course running on a machine, from least to most work,
and what you need to know afterwards: seeds, waveforms, ccache and what the CI
runs. This is what used to live in the README until it was trimmed; here it is
whole.

The shortcut: `make doctor` compiles nothing and tells you what is missing and
which command installs it in your package manager.

---

## The commands

The simulator of the course is **Verilator** — free, no licence, and since
version **5.050** it measures **functional coverage** (covergroups), which is a
topic of the course. There is no Questa flow: the `run.do` files and the VHDL
DUT were taken out of the repository.

```sh
make doctor          # can this machine run the course? what is missing and how to install it
make u3/tb-en-objetos            # one section
make                 # the 38 examples (UVM included)
make matrix          # the same, and regenerates docs/verilator.md
make ejercicios      # the 19 solutions: checks that they are still solvable
```

**Start with `make doctor`.** It compiles nothing: it checks that Verilator ≥
5.050, `z3`, `ccache` and the rest are there, and for whatever is missing it
prints the exact command for your package manager. It exists because the two
most expensive failure modes of the course are **silent** —without `z3`,
`randomize()` returns 0 without saying a word; with a Verilator older than
5.050, functional coverage reports 0 % without a warning—, so a student can lose
an afternoon before suspecting the installation.

> [!IMPORTANT]
> **`z3` is needed from day 5 on.** Verilator solves `randomize()` with
> constraints by calling an external SMT solver. Without it, `u5/varios-objetos`, `u6/transactions`, `u7/agents` and
> `u7/sequences` compile, run, and `randomize()` returns 0 without saying a word.
> `apt install z3` / `brew install z3`. The Docker image and the devcontainer
> already ship it.

**Install `ccache` before you start.** Every simulation compiles to a native
binary, and for the sections with UVM that is ~2300 C++ files. With `ccache` on
the `PATH`, `common.sh` exports `OBJCACHE` on its own and the second build does
not do the work again. Measured on `make u4/tests` with Verilator 5.052:

| | 12 cores | 2 cores (free Codespaces) |
|---|--:|--:|
| the first time | ~1 min 30 | ~4 min |
| with `obj_dir` deleted and `ccache` warm | ~15 s | ~15 s |

A `ccache` hit is a file copy, so the second build takes the same on any
machine: the expensive part is paid once. What the cache does **not** do is
speed up the section next door — Verilator renames the symbols by design, and
barely 22 % of the files match between two sections.

And to repeat a random run, `SEED=N`:

```sh
SEED=7 make u7/sequences     # passes +verilator+seed+7; run_sim prints the seed it used
```

To look at waveforms with **GTKWave** —Verilator generates them for free— there
is an opt-in:

```sh
cd code/u2/convencional && VLT_TRACE=1 bash run.sh && gtkwave vtalu.vcd
```

`VLT_TRACE=1` adds Verilator's `--trace` and switches on the
`$dumpfile`/`$dumpvars` of the top, which sits behind an `` `ifdef `` because
without the flag it would not compile.

`make` downloads **UVM 2020.3.1** (Accellera `uvm-core`, the reference
implementation of IEEE 1800.2-2020) into `code/.uvm/` the first time. Every
example has its own `run.sh`; the common flags are in
`code/verilator/common.sh`.

An example **passes** if it compiles, runs, exits with code 0 and its UVM
*Report Summary* closes with 0 `UVM_ERROR`. The only opt-out is `u4/reporting`,
which breaks the scoreboard on purpose so that reporting can be taught.

### Exercises

**Nineteen** of them, in [`code/ejercicios/`](../../code/ejercicios/): `run.sh`
**fails until you solve it**, and the solution sits next to it
(`SOLUCION=1 bash run.sh`). Every directory holds only the files you touch; the
rest of the testbench comes from the section, by reference. Every statement has
an English version (`README.en.md`).

Three of them —`d5b`, `d5c` and `d7-semillas`— are the *coverage closure*
loop done by hand: measure a distribution, write the directed case that fills
the missing bin, and accumulate coverage with a regression of five seeds.

The thirteenth, `d7-final`, is the **capstone**: a four-register APB slave, its
specification, and **nothing else**. The testbench is written whole, from a
blank sheet, and the marker goes in stages — monitor, driver, scoreboard and
coverage, one `STAGE N OK` each. It is handed in with its **verification plan**
filled out: the five columns, the template and the VTALU plan as an example are
in **[`docs/plan-de-verificacion.md`](../plan-de-verificacion.md)**
*(in Spanish)*.

The last two belong to the optional unit and come **after** the capstone.
`d8-ral` reuses the same DUT and the same testbench, with the spec's register
map written as a UVM model —its second stage is marked by two `uvm-core`
sequences nobody wrote—; `d8-fifo` is the **second capstone**: a FIFO with
backpressure, where the scoreboard cannot be a four-row table.

The examples **are run by the CI**, not only by me: on every release it runs the
38 plus the 19 exercise solutions. It does not run on every push nor every night,
and that is on purpose: the UVM ones take minutes each to compile, so the run is
tied to what gets published. The `ejemplos` badge in the README says how the last
one went, not the day somebody ran them by hand.

What works and what does not —with version, date and the coverage number of each
example— is in **[`docs/en/verilator.md`](verilator.md)**. The two
gaps that remain: *transition bins* (`=>`) still do not compile, and `binsof` /
`intersect` inside a cross are ignored.

### Nothing to install: Codespaces

[![Open in Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/leandrotozzi/verifythis)

**This is the default road.** `.devcontainer/` ships Verilator, UVM and ccache
already inside, so the button —or **Code ▸ Codespaces ▸ Create codespace**—
leaves the course running in the browser, from any machine. Free accounts come
with 60 core-hours a month, more than enough for the seven days.

It goes first because on macOS and on Windows installing Verilator ≥ 5.050 is
half an afternoon of work that teaches nothing about UVM. If you are on Linux
with a recent Verilator, skip to the third one.

### With Docker, on your machine

The same image as the devcontainer, with the repository mounted from outside:
you edit with your usual editor and run inside.

```sh
docker build -t verifythis .                              # once, ~7 min
docker run --rm -it -v "$PWD":/work verifythis make u4/tests
```

The `ccache` cache lives in `.ccache/` inside the mounted repository —that is
why it survives the `--rm`—. Details, RAM tuning and limitations in
[`docs/docker.md`](../docker.md) *(in Spanish)*.

### By hand: Verilator ≥ 5.050

On Linux, the distro package is usually behind: check `verilator --version`
before anything else. On Intel macOS, Homebrew no longer builds new formulae, so
it goes from source. The recipe that works (the three traps are all in the
`PATH`):

```sh
brew install m4 bison ccache z3   # the bison on macOS is 2.3, Verilator wants 3.x
git clone --depth 1 --branch v5.052 https://github.com/verilator/verilator
cd verilator
# m4 and bison from brew; flex NOT: brew's generates against another FlexLexer.h and does not link
export PATH="/usr/local/opt/m4/bin:/usr/local/opt/bison/bin:$PATH"
autoconf && ./configure --prefix="$HOME/opt/verilator-5.052"
make -j"$(sysctl -n hw.ncpu)" && make install
```

Afterwards, put `$HOME/opt/verilator-5.052/bin` first in the `PATH`.

The other two packages on that line are not decoration:

- **`z3`** is **mandatory** from day 5 on. Verilator solves `randomize()` with
  constraints by calling an external SMT solver; without it the build passes,
  the simulation runs, and `randomize()` returns 0 — another one that does not
  break, it lies. `u5/varios-objetos`, `u6/transactions`, `u7/agents` and
  `u7/sequences` need it.
- **`ccache`** is picked up by `common.sh` on its own, and it is what makes the
  second UVM section compile in seconds.

<details>
<summary>On Windows: WSL 2</summary>

Once Ubuntu is installed, everything else is identical to Linux.

```powershell
wsl --install -d Ubuntu     # PowerShell as administrator, then reboot
```

Inside Ubuntu, `sudo apt install git make g++ perl ccache z3` and then Verilator
from source, with the recipe above.

> [!IMPORTANT]
> Clone the repository **inside the WSL filesystem** (`~/verifythis`), not in
> `/mnt/c/...`. The bridge to NTFS makes the UVM build take several times
> longer.

For the waveforms: on Windows 11, WSLg opens GTKWave directly. On Windows 10,
install GTKWave natively and open the `.vcd` from `\\wsl$\Ubuntu\home\...`.

Docker Desktop works too, with the same `Dockerfile`.

</details>

### If you cannot even do that

[EDA Playground](https://edaplayground.com) is good for pasting a single class
and experimenting with one concept —polymorphism, a `constraint`, a
`covergroup`—. It does not run the whole course, because the testbenches are
many files, but it is the safety net for whoever cannot install anything today.
And its commercial simulators support the *transition bins* that Verilator does
not yet.

Every example is **self-contained on purpose**: you can copy `code/u4/env/`
somewhere else and run it as is. See [`code/README.md`](../../code/README.md)
*(in Spanish)*.
