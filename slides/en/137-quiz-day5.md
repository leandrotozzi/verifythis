<!-- es-sha: 3e2a98054876 -->
<!-- .slide: class="quiz" -->

## Review · Day 5

#### *1 of 4 · Deep copy*

**`obj1_h = obj2_h`. What did I copy?**

- [x] Nothing: both handles point at the same object
- [ ] Every field of `obj2_h` into `obj1_h`
- [ ] Only the `rand` fields
- [ ] A shallow copy of the first level

> **Nothing** — there is no copy, there is a second name for the same object. If you modify it through one handle, the other sees it. That is where the *MOOCOW* rule comes from: if you are going to modify, copy first.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *2 of 4 · super.do_copy()*

**Why does every `do_copy()` of the hierarchy have to call `super.do_copy()`?**

- [ ] Because UVM requires it in order to register the class
- [ ] So that the object ends up registered in the factory
- [x] Because otherwise the fields of the classes above do not get copied
- [ ] In order to be able to randomize after copying

> **Otherwise the fields from above get lost** — it is the same problem as `convert2string()`: the day somebody puts a new level in the middle, the method stops seeing half the data and nobody warns you.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *3 of 4 · clone()*

**`clone()` returns a `uvm_object`. Why is it recommended to write a `clone_me()` as well?**

- [x] To wrap the `$cast` up in a single place and not repeat it all over the TB
- [ ] Because `clone()` does not copy the data
- [ ] Because `clone()` is deprecated in IEEE 1800.2
- [ ] In order to be able to clone components as well as transactions

> **So as not to repeat the `$cast`** — without it, every place that clones ends up writing its own cast. It is the same old idea: if you are going to repeat it, wrap it up.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *4 of 4 · Constrained Random*

**`A dist {8'h00 := 1, [8'h01:8'hFE] := 1, 8'hFF := 1};` — how often does `A = 8'h00` come up?**

- [ ] A third of the time: they are three entries with the same weight
- [ ] Half: the edges share it between the two of them
- [x] One time in 256: with `:=` the weight is applied to **each value** of the range
- [ ] Never: `:=` only accepts single values, not ranges

> **1 in 256** — `:=` gives weight 1 to *each one* of the 254 values in the middle, so the range weighs 254 against 1 and 1 from the edges. To share the weight out *inside* the range you use `:/`. Both forms compile and run: the difference only shows up in the coverage that does not go up.
