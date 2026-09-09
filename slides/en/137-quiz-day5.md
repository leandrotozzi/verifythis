<!-- es-sha: 347fbfb3851b -->
<!-- .slide: class="quiz" -->

## Review · Day 5

#### *1 of 8 · Deep copy*

**`obj1_h = obj2_h`. What did I copy?**

- [x] Nothing: both handles point at the same object
- [ ] Every field of `obj2_h` into `obj1_h`
- [ ] Only the `rand` fields
- [ ] A shallow copy: the first level is copied and the handles inside get shared

> **Nothing** — there is no copy, there is a second name for the same object. If you modify it through one handle, the other one sees it. Out of that comes the *MOOCOW* rule: if you are going to modify, copy first.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *2 of 8 · super.do_copy()*

**Why does every `do_copy()` in the hierarchy have to call `super.do_copy()`?**

- [ ] Because UVM demands it in order to register the class
- [ ] So that the object ends up registered in the factory
- [x] Because otherwise the fields of the classes above do not get copied
- [ ] Because `do_copy()` is `pure virtual` and the base class has no implementation

> **Otherwise the fields above get lost** — it is the same problem as `convert2string()`: the day somebody puts a new level in the middle, the method stops seeing half the data and nobody warns you.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *3 of 8 · clone()*

**`clone()` returns a `uvm_object`. Why is it recommended to also write a `clone_me()`?**

- [x] To wrap the `$cast` in a single place
- [ ] Because `clone()` does not copy the data
- [ ] Because `clone()` is deprecated in IEEE 1800.2 and `copy()` replaces it
- [ ] To be able to clone components as well as transactions

> **So as not to repeat the `$cast`** — without it, every place that clones ends up writing its own cast. It is the same idea as always: if you are going to repeat it, wrap it.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *4 of 8 · `dist`: `:=` against `:/`*

**`A dist {8'h00 := 1, [8'h01:8'hFE] := 1, 8'hFF := 1};` — how often does `A = 8'h00` come out?**

- [ ] A third of the time: they are three entries with the same weight
- [ ] Half: the edges share it between the two of them
- [x] Once every 256: with `:=` the weight goes to **each value**
- [ ] Never: `:=` only takes single values, not ranges, and the range is dropped

> **1 in 256** — `:=` gives weight 1 to *each one* of the 254 values in the middle, so the range weighs 254 against the 1 and 1 of the edges. To spread the weight *inside* the range you need `:/`. Both spellings compile and run: the difference only shows up in the coverage that does not go up.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *5 of 8 · `randomize() with {}`*

**`cmd.randomize() with { A == 8'hFF; }` — what happens to the constraints the class already had?**

- [ ] They get replaced: for that call only what is inside the braces counts
- [x] They add up: both have to be satisfied
- [ ] They stay switched off until the next `randomize()` without a `with`
- [ ] It depends on the declaration order: the one lower in the file wins

> **They add up** — the `with {}` adds constraints **for that call only**, and erases nothing. That is why it is the tool for closing a bin without writing a new class: three lines at the point of use, and the rest of the stimulus stays what it always was. And that is also why it clashes with a `dist` that already biases the same field: both have to hold at once.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *6 of 8 · constraint_mode()*

**`randomize() with { A == 8'hFF; }` on a field the class spreads with a `dist` returns 0 three times out of four. What is the way around it?**

- [ ] Retry in a `do ... while` until it returns 1
- [x] `constraint_mode(0)` on the `dist` constraint, for that object
- [ ] Raise the weight of the `8'hFF` bin in the `dist` of the class
- [ ] `rand_mode(0)` on the field: it takes the `dist` out and lets the `with` rule

> **Switch off the constraint that gets in the way** — Verilator solves the `dist` by **picking a value first** and only then checking the rest, so the probability of success is the probability of the bin: measured, `with {A == 8'hFF}` solves 25 % of the time. `constraint_mode(0)` switches it off for that object alone and touches nobody else. It is exactly the line the `d6-bins` exercise asks for.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *7 of 8 · rand_mode()*

**What does `cmd.A.rand_mode(0)` do?**

- [ ] It switches off every constraint that mentions that field
- [x] It takes the field out of the draw and leaves it the value it had
- [ ] It randomizes it once and freezes it afterwards
- [ ] It makes the solver resolve it last, after all the other fields

> **It stops being `rand`** — they are the two run-time knobs and they get mixed up often: `rand_mode(0)` takes **a field** out of the draw, `constraint_mode(0)` switches off **a constraint**. One picks *what gets drawn*, the other *which rules hold*. It is what you use to pin one operand by hand and go on randomizing the rest.

---

<!-- .slide: class="quiz" -->

## Review · Day 5

#### *8 of 8 · The order of resolution*

**`rand bit es_reset; rand byte unsigned A;` with `constraint c { es_reset -> A == 8'h00; }`. How often does `es_reset = 1` come out?**

- [ ] Half the time: it is a `rand` bit and nothing forbids it
- [ ] Never: the implication forces it to 0
- [x] 1 in 257: the solver draws among the **solutions**
- [ ] It depends on the seed, and over enough runs it averages out to half

> **1 in 257** — the solver picks uniformly among the *solutions*, not among the values of each field: `es_reset=1` leaves a single combination (`A = 00`) and `es_reset=0` leaves 256. The *"any operation after a reset"* row of the plan does not get filled, and the report does not say why. The answer in the language is `solve es_reset before A`; Verilator accepts it and **does not honour it**, so the portable way around is to ask for the spread of the control field with a `dist`.
