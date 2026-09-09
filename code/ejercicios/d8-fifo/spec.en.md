<!-- es-sha: 466a1c6f4fd4 -->
# Synchronous FIFO with 8 places · specification

> This file is **the spec**. It is the only thing you have to read in order to verify the
> DUT, and it is the only thing you have to believe. If something is not here, it is not
> specified; if the RTL does something this file does not say, the one that is wrong is the RTL.

## What it is for

A buffer between two domains that do not go at the same rate: one writes, another reads,
and the FIFO absorbs the difference. When it cannot absorb any more, it **says so** — that
is *backpressure*, and it is half of the spec.

## Pins

| Signal | Dir | Width | What it is |
|---|:--:|:--:|---|
| `clk` | in | 1 | everything happens on the **rising** edge |
| `rst_n` | in | 1 | asynchronous, active low |
| `wr_en` | in | 1 | *"I want to write `wr_data` on this cycle"* |
| `wr_data` | in | 8 | the data to write |
| `rd_en` | in | 1 | *"I want to read on this cycle"* |
| `rd_data` | out | 8 | the data read |
| `full` | out | 1 | nothing else fits |
| `almost_full` | out | 1 | few places left |
| `empty` | out | 1 | there is nothing to read |
| `almost_empty` | out | 1 | few data left |
| `count` | out | 4 | how many data are inside, from 0 to 8 |

## The three numbers

| | Value | It means |
|---|:--:|---|
| `DEPTH` | **8** | places |
| `AF` | **6** | `almost_full` is at 1 with **6 or more** data inside |
| `AE` | **2** | `almost_empty` is at 1 with **2 or fewer** data inside |

## How it behaves

1. **There is no handshake.** The FIFO always serves: there is no signal that says
   *"wait"*. Whoever asks has to look at the flags **beforehand**.
2. A write goes in if there is room. A read takes something out if there is anything.
3. The data comes out **in the same order** it went in. Always.
4. After the reset the FIFO is empty: `count = 0`, `empty = 1`, `full = 0`.

## The small print

Four things that are here, loose and not underlined, as they would be in a real
spec. All four hang the first testbench.

- **The flags describe the state *before* the edge.** They are combinational
  on `count`: what you see on a cycle is the occupancy the FIFO is going to
  serve **that** cycle with, not the result of serving it.

- **`rd_data` is registered.** The data appears on the cycle **after** the one
  the read was asked for on. A monitor that reads it on the same edge as `rd_en`
  reports the previous piece of data, and all the comparisons shift by one.

- **Writing with the FIFO full is not an error.** The data gets **silently
  discarded**: there is no overflow flag, there is no error signal, and `count` does
  not move. The same the other way round: reading with the FIFO empty takes nothing out and `rd_data`
  does not change.

- **A write and a read on the same cycle, with the FIFO full, goes in.**
  The read frees the place on the same edge. The other way round it does **not** work: reading
  from an empty FIFO on the same cycle a write happens does not give that data back —
  the data goes in at the back, and the read comes out of the front.

## The verification plan

Seven rows. It is the table that gets filled in before writing the testbench, and it is where
the `covergroup` comes from — not the other way round.

| Feature | Scenario | Stimulus | Check | Measure |
|---|---|---|---|---|
| order | what goes in comes out in order | random | scoreboard, queue | `pedido` |
| filling | fill up to `full` and go past it | directed | scoreboard: the extra data gets discarded | cross `escribe_llena` |
| emptying | empty down to `empty` and go past it | directed | scoreboard: nothing comes out | cross `lee_vacia` |
| flags | `full`, `empty` and the two *almost* on every cycle | random | scoreboard: prediction against observation | `lleno`, `vacio`, `casi_lleno`, `casi_vacio` |
| `count` | it matches the occupancy of the model | random | scoreboard | `ocupacion` |
| simultaneous | read and write on the same cycle | random + directed | scoreboard | bin `simultaneo` |
| simultaneous at the edge | read and write with the FIFO full, and with it empty | directed | scoreboard | cross `pedido_x_ocupacion` |

> The **flags** row is the one that makes this exercise different. A
> scoreboard that only compares what comes out of `rd_data` closes the other six
> rows and leaves this one unverified — and it is the row where the bug of `+BUG=1` lives.
