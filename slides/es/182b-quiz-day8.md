<!-- .slide: class="quiz" -->

## Repaso · Día 8

#### *1 de 8 · El string de acceso*

**`CLR` se limpia solo cuando le escribís un 1. Lo declarás `"WOC"`, y `bit_bash` y `mirror(UVM_CHECK)` dan cero errores. ¿Qué pasó?**

- [ ] Nada: `WOC` es el acceso que describe un campo que se limpia al escribirlo
- [ ] `WOC` no está en el LRM, así que UVM lo trata como un `RW` cualquiera
- [x] Los dos saltean los accesos `WO*`: ese bit no se testeó
- [ ] El predictor deja el espejo en `x`, y una comparación contra `x` siempre pasa

> **Verde no es chequeado** — `uvm_reg_bit_bash_seq.svh:129-133` saltea todo campo cuyo acceso empiece con `WO` (*"you are not supposed to read them"*), y `do_check` lo saca de la máscara de comparación (`uvm_reg.svh:2782-2788`). El único rastro está en los tiempos: el bashing de `CTRL` dura cuatro transferencias menos. El acceso correcto es `WC` (o `W1C`), y con él el bit sí se batea. Un acceso `WO*` es la forma más barata que hay de apagar un chequeo sin enterarse.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 8

#### *2 de 8 · Predicción automática o explícita*

**¿Qué cambia entre `set_auto_predict(1)` y enganchar un `uvm_reg_predictor` al monitor?**

- [x] Con auto-predict el modelo cree lo que **quiso** mandar, no lo que pasó
- [ ] Nada: el predictor es la implementación interna del auto-predict
- [ ] El predictor es más rápido: no arma la transaction del bus
- [ ] El auto-predict sólo sirve para el frontdoor, y el predictor también para el backdoor

> **El que chequea no puede creerle al que estimula** — con `set_auto_predict(1)`, `model.CTRL.write()` actualiza el espejo en el momento de la llamada, antes de que el bus haya hecho nada: si el driver manda mal la transferencia, el modelo sigue convencido. Con el predictor, el espejo cambia recién cuando el monitor vio el cable. Es el mismo dibujo del scoreboard del capstone, con una pieza de la librería en lugar de una clase a mano. Y es gratis: el monitor y su analysis port **ya estaban**.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 8

#### *3 de 8 · volatile*

**`STATUS` cambia solo, sin que nadie le escriba. ¿Qué querés decir al declararlo `volatile` en `configure()`?**

- [x] Que el espejo no es evidencia: el valor pudo cambiar sin pasar por el bus
- [ ] Que UVM lo va a releer del DUT antes de cada comparación, para no equivocarse
- [ ] Que el campo queda fuera del mapa y deja de tener dirección
- [ ] Que hay que leerlo por backdoor, porque el frontdoor no llega a tiempo

> **El espejo deja de ser evidencia** — un modelo predice *"lo que escribí es lo que voy a leer"*, y para un campo `volatile` esa frase es falsa. Los dos `UVM_WARNING GET_MIRRORED_VAL/VOL` del ejemplo son la librería diciendo exactamente eso, y están en la salida a propósito. Lo que sí hay que chequear se chequea donde se sabe: en el **scoreboard**, y en el modelo va `set_compare(UVM_NO_CHECK)` sobre ese campo para que RAL no invente un error.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 8

#### *4 de 8 · mirror() contra read()*

**`model.CTRL.read(status, data)` y `model.CTRL.mirror(status, UVM_CHECK)`. ¿En qué se diferencian?**

- [ ] `read` va por el bus y `mirror` se queda en el espejo, sin generar una transferencia
- [ ] `mirror` escribe el espejo en el DUT, para dejar a los dos iguales
- [ ] `read` actualiza el espejo y `mirror` no lo toca, para no tapar un error
- [x] Las dos leen del DUT; `mirror` además compara contra lo que el modelo creía

> **`mirror` es un scoreboard de registros en una palabra** — las dos leen del DUT; la diferencia es que `mirror` compara contra lo que el modelo creía **antes** de la lectura, y si no coincide reporta un `uvm_error` sin que nadie escriba un chequeo. Y una lectura *es* una predicción: las dos actualizan el espejo después.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 8

#### *5 de 8 · Quién sabe del bus*

**¿Qué sabe el `uvm_reg_block` sobre el APB?**

- [ ] La dirección base y el ancho de `PADDR`, que le llegan por el `uvm_reg_map`
- [x] Nada: el único que sabe del bus es el adapter
- [ ] Todo: por eso hay un modelo de registros por protocolo
- [ ] Los tiempos de SETUP y ACCESS, para predecir el wait state de la lectura

> **El modelo no sabe que abajo hay un APB** — cambiás el adapter y el mismo modelo maneja un AHB. El adapter son veinte líneas, una vez por protocolo, y es el archivo que te viene con un VIP comprado. Ojo con una: `bus2reg` lo llama **también el predictor**, con el item que vio el monitor, así que un adapter que dependa de algo que puso el driver funciona en un sentido y falla en el otro.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 8

#### *6 de 8 · DPI y el tiempo*

**Una `import "DPI-C" function` del golden model, ¿puede esperar un flanco de reloj?**

- [ ] Sí, poniendo un `#1` adentro del `.c`
- [x] No: una `function` corre en tiempo cero
- [ ] Sí, siempre que el `.c` se compile con el soporte de timing de Verilator
- [ ] Sí: el simulador suspende el hilo de C mientras dura la llamada

> **Tiempo cero, como cualquier `function`** — para consumir tiempo hace falta `import "DPI-C" task`, y con una aclaración que casi todos los tutoriales se saltean: el C no puede bloquear por sí mismo. Una task de DPI consume tiempo **sólo** si se declara `context` y desde el C llama de vuelta a una `export "DPI-C" task` de SystemVerilog, que es la que espera el flanco. Y ahí ya no es un golden model, es un modelo de bus.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 8

#### *7 de 8 · undefined reference*

**El `.c` está escrito y compila, y el link falla con *undefined reference* a la función del golden model. ¿Qué mirás primero?**

- [ ] Que falte el flag de DPI en la línea de `verilator`
- [ ] Que el `.c` esté en un `-f` aparte y no mezclado con los `.sv`
- [x] El nombre, y el `extern "C"`: el símbolo pudo salir decorado
- [ ] Que la `function` de SystemVerilog esté declarada `virtual` para exportar el símbolo

> **El compilador no cruza las dos declaraciones: el que las junta es el linker** — de ahí que el error hable de algo que está escrito, ahí, a la vista. Casi siempre es una de dos: el nombre no coincide letra por letra, o el archivo se compiló como C++ y el símbolo salió con el nombre decorado. Eso último es literal acá: Verilator le pasa los fuentes del usuario al compilador de C++, así que el `.c` necesita su `extern "C"`. Y no hay flag de DPI: el `.c` va en la línea de `verilator` como un fuente más.

---

<!-- .slide: class="quiz" -->

## Repaso · Día 8

#### *8 de 8 · El scoreboard que nunca gritó*

**El scoreboard con golden model en C corre mil operaciones y no reporta ni una. ¿Alcanza?**

- [ ] Sí: mil comparaciones sin una sola diferencia es la definición de verificado
- [ ] Sí, siempre que además la cobertura funcional haya cerrado al 100 %
- [ ] No, porque los dos lados comparten el `enum` de opcodes y se anulan entre sí
- [x] No: un scoreboard que nunca vio un error no está probado

> **Hay que romper el modelo a propósito** — `vtalu_golden_bug(1)` muta la multiplicación y el `run.sh` exige que el scoreboard grite. Si no grita, el testbench está comparando contra sí mismo y nadie se iba a enterar: es el mismo test de mutación que el corrector del capstone hace con `+BUG=1`, del otro lado del cable. Y el `enum` duplicado es real pero es otro síntoma: si fallan **todas** las comparaciones a la vez, es el mapeo; si falla una de cada seis, es el DUT.
