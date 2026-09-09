<!-- es-sha: 2ee9c4b81bb9 -->
<!-- .slide: class="quiz" -->

## Review · Day 2

#### *1 of 8 · Handle and object*

**`rectangle rectangle_h;` — after that line, how many objects are there?**

- [x] None: `rectangle_h` is `null` until somebody calls `new()`
- [ ] One, with `length` and `width` at 0
- [ ] One half built: the fields exist but the constructor has not run
- [ ] It depends on whether the class has a constructor

> **None** — declaring a handle reserves nothing. There is the difference with a `struct`, which the simulator reserves the moment it sees it. And using the handle before the `new()` does not fail at compile time: it blows up in the middle of the simulation.

---

<!-- .slide: class="quiz" -->

## Review · Day 2

#### *2 of 8 · Polymorphism*

**A variable of type `trago` holds a `fernet` object. If `servir()` is not `virtual`, what gets executed?**

- [ ] `fernet`'s `servir()`
- [ ] A compile error
- [x] `trago`'s `servir()`
- [ ] Both, the base class one first

> **`trago`'s** — without `virtual`, SystemVerilog looks at the **type of the variable**, not at the object's. It is literally what `code/u3/polimorfismo/01-sin-virtual` prints: *"A generic trago cannot be served"*.

---

<!-- .slide: class="quiz" -->

## Review · Day 2

#### *3 of 8 · Abstract classes*

**What do I gain by using an abstract class with `pure virtual` methods instead of a base class whose method does `$fatal`?**

- [ ] Nothing, it is a matter of style
- [x] That the error moves from simulation to the compiler
- [ ] That the base class can be instantiated
- [ ] That the simulator can pick the most specific override at run time

> **The error moves to the compiler** — with `$fatal` you find out halfway through the simulation that an override was missing. With `pure virtual` it does not compile. Catching it earlier is always cheaper.

---

<!-- .slide: class="quiz" -->

## Review · Day 2

#### *4 of 8 · Static variables*

**I instantiate 10 objects of a class that has a `static` variable. How many copies are there in memory?**

- [ ] 10, one per object
- [ ] 0 until somebody writes it: the memory is reserved on first access
- [x] 1, shared by every instance
- [ ] It depends on the simulator

> **A single one** — and it exists even if you instantiate no object at all. That is what makes it useful for global TB data, and what makes it dangerous if you leave it public.

---

<!-- .slide: class="quiz" -->

## Review · Day 2

#### *5 of 8 · Static methods*

**Why is it worth declaring the static variable `protected` and exposing it with static methods?**

- [x] To be able to change the data structure without touching whoever uses it
- [ ] Because a `static` without `protected` is reserved once per instance
- [ ] So that it takes up less memory
- [ ] Because UVM demands it

> **To be able to change it later** — if the queue is out in the open, the day you swap it for another structure you have to go and fix every place that touched it. Encapsulating is being able to change your mind.

---

<!-- .slide: class="quiz" -->

## Review · Day 2

#### *6 of 8 · Parameterized classes*

**`bandeja#(fernet)` and `bandeja#(mojito)` have a `static` queue inside. Do they share the queue?**

- [ ] Yes, `static` is a single one for everybody
- [ ] Yes: the parameter changes the type of the methods, not the static storage
- [ ] It depends on whether they get instantiated or not
- [x] No: each specialization is a different class, with its own queue

> **They do not share it** — SystemVerilog generates **one class per combination of parameters**. `static` is unique inside each one of those classes, not across all of them. UVM leans on this all the time.

---

<!-- .slide: class="quiz" -->

## Review · Day 2

#### *7 of 8 · The factory pattern*

**What problem does the factory pattern solve?**

- [ ] Creating objects faster
- [x] Deciding at run time which subtype to build
- [ ] Avoiding having to declare classes
- [ ] Centralizing the `new()`s in one class, to be able to count and free them

> **Deciding the subtype at runtime** — without hardcoding the `new`: you ask the factory for an object and it decides which one. It is the piece that is later going to let you change the stimulus of a whole test without touching the code of the `env`.

---

<!-- .slide: class="quiz" -->

## Review · Day 2

#### *8 of 8 · $cast*

**When does a `$cast(destination, source)` succeed?**

- [ ] Always: it converts any class into any other
- [ ] Only between classes with no inheritance
- [ ] When the two classes have the same fields, even if they are not related
- [x] Only if the object in `source` is of the class of `destination` or of a derived one

> **Only if the object allows it** — `$cast` checks **at runtime** and returns 0 if it does not work. That is why UVM's factory is more comfortable than the `cantina` of the section: `type_id::create()` returns the right type and saves you the cast.
