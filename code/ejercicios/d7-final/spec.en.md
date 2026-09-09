<!-- es-sha: f99766551b39 -->
# APB_REGS — specification

An **APB3** slave with four 32-bit registers. It is all there is: there is no
testbench, there is no example to copy from. This is what they hand you on Monday.

## The pins

| Signal | Dir | Width | What it is |
|---|:--:|:--:|---|
| `PCLK` | in | 1 | clock. Everything is synchronous to the **rising edge** |
| `PRESETn` | in | 1 | **asynchronous** reset, active low |
| `PSEL` | in | 1 | the master selected this slave |
| `PENABLE` | in | 1 | second cycle onwards of the transfer |
| `PWRITE` | in | 1 | 1 = write, 0 = read |
| `PADDR` | in | 8 | byte address. `PADDR[1:0]` is ignored |
| `PWDATA` | in | 32 | data to write |
| `PRDATA` | out | 32 | data read. Valid on the edge on which `PREADY` is high |
| `PREADY` | out | 1 | the slave has finished |
| `PSLVERR` | out | 1 | error. Valid together with `PREADY` |

## The protocol

A transfer is **two phases**, and that is the difference from the handshake of
the VTALU:

```
         __    __    __    __    __    __
PCLK   _|  |__|  |__|  |__|  |__|  |__|  |__
        IDLE | SETUP  |    ACCESS    | IDLE
             ______________________
PSEL   _____|                      |________
                   ________________
PENABLE __________|                |_________
             ______________________
PADDR  -----<     valid address     >---------
                          _________
PREADY -__________________|        |_________   (read: one wait state)
```

- **SETUP** — one cycle. `PSEL=1`, `PENABLE=0`, and `PADDR` / `PWRITE` / `PWDATA`
  already valid.
- **ACCESS** — `PENABLE=1`. It holds until the master **samples
  `PREADY` high** on a rising edge. That is where the transfer ends.
- **Writes do not wait**: `PREADY` is high from the first cycle of
  ACCESS. **Reads put in one wait state**: `PREADY` goes up on the second.
- `PRDATA` and `PSLVERR` are valid **on the edge on which `PREADY` is high**, and
  only there.
- Between two transfers `PSEL` can stay high (*back to back*) or go down.

## The register map

| Addr | Name | Access | Contents |
|---|---|:--:|---|
| `0x00` | `CTRL` | RW | bit 0 = `EN` · bit 1 = `CLR` |
| `0x04` | `SCRATCH` | RW | 32 free bits |
| `0x08` | `ACC` | RO | accumulator |
| `0x0C` | `STATUS` | RO | bit 0 = `EN` · bit 1 = `OVF` |

**`CTRL`**
- `EN` is an ordinary bit: it gets written, it gets read, and it stays.
- `CLR` is **autoclear**: writing a 1 puts `ACC` and `OVF` at zero **on that
  same edge**, and the bit always reads **0**. There is no way of reading it at 1.

**`SCRATCH`**
- It gets written and read. And besides: **every write to `SCRATCH`, with `EN=1`, adds
  the written data to `ACC`**. With `EN=0` `SCRATCH` gets written and `ACC` does not move.

**`ACC`** — read only. Writing it **does nothing and does not give an error either**: the
transfer ends normally, with `PSLVERR=0`, and the register does not change.

**`STATUS`** — read only, same rule. `OVF` switches on when the sum in
`ACC` overflows the 32 bits, and it is **sticky**: it stays at 1 until the next `CLR`.

## Errors

- Any address **from `0x10` upwards** answers with `PSLVERR=1`. On a
  read, `PRDATA` is 0.
- Writing a read-only register is **not** an error: `PSLVERR=0`.

## Reset

`PRESETn` is asynchronous and active low. After the reset: `EN=0`, `OVF=0`,
`SCRATCH=0`, `ACC=0`.

## The small print

Everything above is said once and in one line. These are the four that
hang the first testbench, together and in one single place — because in a real
spec they are not going to be together nor in one single place:

1. The read has **one wait state**. A driver that takes for granted that ACCESS
   lasts one cycle reads `PRDATA` one cycle too early and does not fail every time.
2. `CTRL.CLR` **never reads as 1**. A scoreboard that predicts *"I wrote 2, I read
   2"* fails on the first read of `CTRL`.
3. Writing `ACC` or `STATUS` **does not give an error**. It is the trap the other way round: the
   scoreboard that expects `PSLVERR=1` there fails.
4. `ACC` only adds with `EN=1`. Modelling the accumulator **without** modelling `EN` is the
   bug `+BUG=1` puts into the DUT on purpose.

## The verification plan

What has to be covered, which is what the `covergroup` has to measure. The five
columns are the usual ones — they are explained, with the plan of the VTALU as an
example, in [`docs/plan-de-verificacion.md`](../../../docs/plan-de-verificacion.md) (in Spanish):

| # | Feature | Scenario | Stimulus | Check | Measure |
|:--:|---|---|---|---|---|
| 1 | registers | write and read the four | directed sequence | scoreboard | cross `addr` × `write` |
| 2 | registers | write a read-only one | random | scoreboard: it does not change, `PSLVERR=0` | bin `acc`/`status` × `wr` |
| 3 | errors | unmapped address | random | scoreboard: `PSLVERR=1` | bin `unmapped` |
| 4 | accumulator | add with `EN=1` | random | scoreboard: predicted `ACC` | bin `scratch` × `wr` |
| 5 | accumulator | do **not** add with `EN=0` | random | scoreboard: `ACC` does not move | bin `ctrl` × `wr` |
| 6 | accumulator | overflow of `ACC` | random | scoreboard: `STATUS[1]` | bin `ovf` |
| 7 | control | `CLR` | random | scoreboard: `ACC=0`, `OVF=0` | bin `clr` |

Seven rows, and none of them says *"test the APB"*: a row is a scenario that can
be provoked, checked and measured. If your covergroup has a bin that is not in
this table, either you are missing a row or you have a spare bin.
