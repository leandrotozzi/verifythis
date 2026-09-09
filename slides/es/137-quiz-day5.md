<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *1 de 8 · Copia profunda*

**`obj1_h = obj2_h`. ¿Qué copié?**

- [x] Nada: los dos handles apuntan al mismo objeto
- [ ] Todos los campos de `obj2_h` a `obj1_h`
- [ ] Sólo los campos `rand`
- [ ] Una copia superficial: el primer nivel se copia y los handles de adentro se comparten

> **Nada** — no hay copia, hay un segundo nombre para el mismo objeto. Si lo modificás por un handle, el otro lo ve. De ahí sale la regla del *MOOCOW*: si vas a modificar, copiá primero.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *2 de 8 · super.do_copy()*

**¿Por qué cada `do_copy()` de la jerarquía tiene que llamar a `super.do_copy()`?**

- [ ] Porque UVM lo exige para registrar la clase
- [ ] Para que el objeto quede registrado en la factory
- [x] Porque si no, los campos de las clases de arriba no se copian
- [ ] Porque `do_copy()` es `pure virtual` y la clase base no tiene implementación

> **Si no, se pierden los campos de arriba** — es el mismo problema que `convert2string()`: el día que alguien mete un nivel nuevo en el medio, el método deja de ver la mitad de los datos y no te avisa nadie.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *3 de 8 · clone()*

**`clone()` devuelve un `uvm_object`. ¿Por qué se recomienda escribir además un `clone_me()`?**

- [x] Para encapsular el `$cast` en un solo lugar
- [ ] Porque `clone()` no copia los datos
- [ ] Porque `clone()` está deprecado en IEEE 1800.2 y lo reemplaza `copy()`
- [ ] Para poder clonar componentes además de transacciones

> **Para no repetir el `$cast`** — sin él, cada lugar que clona termina escribiendo su propio casteo. Es la misma idea de siempre: si lo vas a repetir, encapsulalo.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *4 de 8 · `dist`: `:=` contra `:/`*

**`A dist {8'h00 := 1, [8'h01:8'hFE] := 1, 8'hFF := 1};` — ¿cada cuánto sale `A = 8'h00`?**

- [ ] Un tercio de las veces: son tres entradas con el mismo peso
- [ ] La mitad: los bordes se reparten entre los dos
- [x] Una vez cada 256: con `:=` el peso va a **cada valor**
- [ ] Nunca: `:=` sólo acepta valores sueltos, no rangos, y el rango se descarta

> **1 de cada 256** — `:=` le da peso 1 a *cada uno* de los 254 valores del medio, así que el rango pesa 254 contra 1 y 1 de los bordes. Para repartir el peso *dentro* del rango va `:/`. Las dos formas compilan y corren: la diferencia sólo aparece en la cobertura que no sube.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *5 de 8 · `randomize() with {}`*

**`cmd.randomize() with { A == 8'hFF; }` — ¿qué pasa con las constraints que la clase ya tenía?**

- [ ] Se reemplazan: para esa llamada vale sólo lo que está entre las llaves
- [x] Se suman: hay que satisfacer las dos
- [ ] Quedan apagadas hasta el próximo `randomize()` sin `with`
- [ ] Depende del orden de declaración: gana la que está más abajo en el archivo

> **Se suman** — el `with {}` agrega constraints **sólo para esa llamada** y no borra nada. Por eso es la herramienta para cerrar un bin sin escribir una clase nueva: tres líneas en el punto de uso, y el resto del estímulo sigue siendo el de siempre. Y por eso también choca con un `dist` que ya sesgue el mismo campo: las dos tienen que dar a la vez.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *6 de 8 · constraint_mode()*

**`randomize() with { A == 8'hFF; }` sobre un campo que la clase reparte con `dist` devuelve 0 tres de cada cuatro veces. ¿Cuál es el rodeo?**

- [ ] Reintentar en un `do ... while` hasta que devuelva 1
- [x] `constraint_mode(0)` sobre la constraint del `dist`, para ese objeto
- [ ] Subir el peso del bin `8'hFF` en el `dist` de la clase
- [ ] `rand_mode(0)` sobre el campo: saca el `dist` de la ecuación y deja mandar al `with`

> **Apagar la constraint que estorba** — Verilator resuelve el `dist` **eligiendo un valor primero** y recién después chequea el resto, así que la probabilidad de éxito es la del bin: medido, `with {A == 8'hFF}` resuelve el 25 % de las veces. `constraint_mode(0)` la apaga sólo para ese objeto y no toca a nadie más. Es exactamente la línea que pide el ejercicio `d6-bins`.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *7 de 8 · rand_mode()*

**¿Qué hace `cmd.A.rand_mode(0)`?**

- [ ] Apaga todas las constraints que mencionan ese campo
- [x] Saca el campo del sorteo y le deja el valor que tenía
- [ ] Lo randomiza una sola vez y después lo congela
- [ ] Hace que el solver lo resuelva último, después de todos los demás campos

> **Deja de ser `rand`** — son las dos perillas de tiempo de ejecución y se confunden seguido: `rand_mode(0)` saca **un campo** del sorteo, `constraint_mode(0)` apaga **una constraint**. Una elige *qué se sortea*, la otra *qué reglas valen*. Sirve para fijar un operando a mano y seguir randomizando el resto.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 5

#### *8 de 8 · El orden de resolución*

**`rand bit es_reset; rand byte unsigned A;` con `constraint c { es_reset -> A == 8'h00; }`. ¿Cada cuánto sale `es_reset = 1`?**

- [ ] La mitad de las veces: es un bit `rand` y nada lo prohíbe
- [ ] Nunca: la implicación lo fuerza a 0
- [x] 1 de cada 257: el solver sortea entre las **soluciones**
- [ ] Depende de la semilla, y con suficientes corridas promedia la mitad

> **1 de cada 257** — el solver elige uniformemente entre las *soluciones*, no entre los valores de cada campo: `es_reset=1` deja una sola combinación (`A = 00`) y `es_reset=0` deja 256. El bin *"cualquier operación después de un reset"* del plan no se llena, y el reporte no dice por qué. La respuesta del lenguaje es `solve es_reset before A`; Verilator la acepta y **no la respeta**, así que el rodeo portable es pedir el reparto del campo de control con un `dist`.
