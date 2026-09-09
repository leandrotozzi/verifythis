<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *1 de 4 · Copia profunda*

**`obj1_h = obj2_h`. ¿Qué copié?**

- [x] Nada: los dos handles apuntan al mismo objeto
- [ ] Todos los campos de `obj2_h` a `obj1_h`
- [ ] Sólo los campos `rand`
- [ ] Una copia superficial del primer nivel

> **Nada** — no hay copia, hay un segundo nombre para el mismo objeto. Si lo modificás por un handle, el otro lo ve. De ahí sale la regla del *MOOCOW*: si vas a modificar, copiá primero.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *2 de 4 · super.do_copy()*

**¿Por qué cada `do_copy()` de la jerarquía tiene que llamar a `super.do_copy()`?**

- [ ] Porque UVM lo exige para registrar la clase
- [ ] Para que el objeto quede registrado en la factory
- [x] Porque si no, los campos de las clases de arriba no se copian
- [ ] Para poder randomizar después de copiar

> **Si no, se pierden los campos de arriba** — es el mismo problema que `convert2string()`: el día que alguien mete un nivel nuevo en el medio, el método deja de ver la mitad de los datos y no te avisa nadie.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *3 de 4 · clone()*

**`clone()` devuelve un `uvm_object`. ¿Por qué se recomienda escribir además un `clone_me()`?**

- [x] Para encapsular el `$cast` en un solo lugar y no repetirlo en todo el TB
- [ ] Porque `clone()` no copia los datos
- [ ] Porque `clone()` está deprecado en IEEE 1800.2
- [ ] Para poder clonar componentes además de transacciones

> **Para no repetir el `$cast`** — sin él, cada lugar que clona termina escribiendo su propio casteo. Es la misma idea de siempre: si lo vas a repetir, encapsulalo.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *4 de 4 · Constrained Random*

**`A dist {8'h00 := 1, [8'h01:8'hFE] := 1, 8'hFF := 1};` — ¿cada cuánto sale `A = 8'h00`?**

- [ ] Un tercio de las veces: son tres entradas con el mismo peso
- [ ] La mitad: los bordes se reparten entre los dos
- [x] Una vez cada 256: con `:=` el peso se aplica a **cada valor** del rango
- [ ] Nunca: `:=` sólo acepta valores sueltos, no rangos

> **1 de cada 256** — `:=` le da peso 1 a *cada uno* de los 254 valores del medio, así que el rango pesa 254 contra 1 y 1 de los bordes. Para repartir el peso *dentro* del rango va `:/`. Las dos formas compilan y corren: la diferencia sólo aparece en la cobertura que no sube.
