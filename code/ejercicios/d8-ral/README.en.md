<!-- es-sha: f86e4de9cb62 -->
# Day 8 · RAL — modelling the register map

It is the first thing you get asked for in a project with registers, and it is literally this:
they give you the table of the spec and you give back the model.

The DUT is the one from the capstone —the APB slave with four registers— and so is the
testbench: the interface, the transaction, the driver, the monitor and the agent come
from [`d7-final/solucion/`](../d7-final/solucion/), so this exercise runs even if you
have not finished the capstone yet. The adapter, the predictor and the three
tests come from [`code/u9/ral/`](../../u9/ral/) and do not get touched.

**Of all that, the only thing you write is the register model.**

```sh
bash run.sh
```

## What is asked

**`apb_reg_block.svh`** — the table of
[`../d7-final/spec.en.md`](../d7-final/spec.en.md), section *The register map*,
written as a UVM model. Four registers, six fields, four addresses.

| Addr | Name | Access | Fields |
|---|---|:--:|---|
| `0x00` | `CTRL` | RW | `EN` bit 0 · `CLR` bit 1, **autoclear** |
| `0x04` | `SCRATCH` | RW | 32 bits |
| `0x08` | `ACC` | RO | 32 bits, and it **changes on its own** |
| `0x0C` | `STATUS` | RO | `EN` bit 0 · `OVF` bit 1, and they **change on their own** |

The checker goes in stages and each one prints its `STAGE N OK`:

1. **The map.** Without simulating anything: the model gets printed and compared with the
   table. An offset or a width that is wrong shows up here.
2. **The accesses.** `uvm_reg_hw_reset_seq` and `uvm_reg_bit_bash_seq`, which come from
   `uvm-core` and know nothing about this DUT: they read your model and generate the stimulus and
   the check. They are **the tests you did not write**, and they are the whole argument
   in favour of RAL.
3. **What the model cannot predict.** `ACC` and `STATUS` have an address but
   they are not registers: their value gets produced by a write to *another* address. A
   model that does not say so gives false positives, and the false positive belongs to the model,
   not to the DUT.

Done when `bash run.sh` prints the three stages and ends with `EXERCISE OK`.

## How to run it

```sh
bash run.sh              # with your file
SOLUCION=1 bash run.sh   # with the one in solucion/, to compare
```

The model prints itself, and it is the first thing worth looking at:

```sh
bash run.sh 2>&1 | grep MAPA
```

## How long it takes

It compiles the whole of UVM, including `uvm-core/src/reg`. Measured with Verilator 5.052:

| | 12 cores | 2 cores (free Codespaces) |
|---|---|---|
| the first time | ~1 min 30 | ~4 min |
| the following ones, with `ccache` | ~15 s | ~15 s |

## Hints, in order of usefulness

- **`CLR` is not RW.** The spec says *"writing a 1 puts `ACC` and `OVF` at zero, and
  the bit always reads 0"*. UVM has an access with that exact name, and it is not
  `WO`. If you put `RW` on it, stage 1 passes and **stage 2** tells you so with the
  number of the bit — which is exactly what `bit_bash` does well.
- The `volatile` argument of `configure()` does not change the prediction: it is a
  declaration of intent, and UVM uses it to warn you with a `UVM_WARNING`
  when you read the mirror of a field that changes behind your back.
- `set_compare(UVM_NO_CHECK)` goes on the **field**, not on the register, and it
  switches off only the `mirror(UVM_CHECK)`. The read goes on updating the mirror:
  a read *is* a prediction.
- `build()` of a `uvm_reg_block` **is not a `build_phase`**. A block is a
  `uvm_object`: nobody calls it for you. The test calls it, one line after the
  `create()`.
- If `bit_bash` reports nothing about a register, check whether you added it to the
  map. A register that is not in any map does not exist for the sequence.

## What it practises

The whole of the RAL section, which is short on purpose: the model, the `uvm_reg_field` and its
chain of accesses, `add_reg` and the map. And an idea that is not about UVM: **the
difference between a register and an address**.
