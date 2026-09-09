<!-- .slide: id="apendice-trampas" -->

## Apéndice · Las veinte trampas mudas

#### *Compila, corre, y miente*

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| La cobertura da **0 %** | falta el `new()` o el `sample()` del covergroup | un `sample()` por transacción, en el subscriber | Cobertura funcional |
| La hija corre el método de **la madre** | sin `virtual`, SV resuelve por el **tipo de la variable**, en compilación | `virtual` en todo método que alguien vaya a extender | Polimorfismo |
| El component lee **la config de otro** | `get(null, "*", …)` devuelve lo primero que matchee | `get(this, "", …)`, y `+UVM_CONFIG_DB_TRACE` | Tests |
| El test pasa con **el estímulo equivocado** | el `set_type_override()` llegó **después** del `create()` del env | el override primero, siempre. `+TOPOLOGY` lo delata | El env |

- Ninguna de estas cuatro da un warning. Ninguna deja la regresión en rojo. Todas
  se descubren semanas después, o no se descubren

Note:
Este apéndice es el que hay que imprimir y pegar al lado del monitor. Las veinte
están repartidas en siete secciones porque cada una aparece cuando aparece el
concepto, pero se necesitan juntas — y se necesitan en el peor momento.
La tesis del apéndice está en el subtítulo, y vale enunciarla como regla general
del oficio: **en verificación, el error caro no es el que rompe, es el que
miente.** Un error de compilación cuesta dos minutos. Un testbench que pasa
midiendo lo que no es cuesta un tape-out.
La cuarta fila es la que más duele en un equipo grande, porque el que la comete
no es el que la sufre: alguien agrega un override en su test, alguien más mueve
el `create()`, y el estímulo cambia sin que nadie toque el archivo del estímulo.
Por eso el `+TOPOLOGY` de los agents es tan barato: son diez segundos de leer
el árbol que UVM armó de verdad, contra el que uno dibujó en la cabeza.

---

## Apéndice · Las veinte trampas mudas

#### *El que publica y el que escucha*

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| El subscriber cuenta **0** y el monitor imprime 1000 | falta el `connect()` en el `connect_phase` | corregir cruzado: contra lo que dice el que ya andaba | Analysis ports · d4 |
| El monitor **no publica nunca**, y grita el scoreboard | falta `bfm.command_monitor_h = this` en el `build_phase` | el `uvm_fatal` aparece en la clase que **no** tiene la culpa | Analysis ports |
| La copia **pierde los campos de la madre** | un `do_copy()` que no llama a `super.do_copy(rhs)` | todos los `do_copy()` llaman primero al de arriba | Jerarquías |
| Dos transactions distintas **comparan iguales** | `super.do_compare()` llamado en una línea suelta y descartado | encadenado con `&&`, nunca suelto | Transactions |

- Las cuatro tienen la misma forma: **el que falla no es el que se equivocó.** Por
  eso el primer reflejo —abrir el archivo que gritó— es el reflejo equivocado

Note:
La fila del `bfm.command_monitor_h = this` es la que mejor enseña el patrón, y
conviene contarla como historia: el que se olvida esa línea ve un `uvm_fatal` del
scoreboard, abre el scoreboard, y el scoreboard está perfecto. El monitor —que es
el que se equivocó— no dice absolutamente nada, porque su `always` de la
interface nunca lo llamó.
La regla que sale de ahí, y que vale para las cuatro: cuando algo grita, subí una
capa. El que reporta un mismatch es el último de la cadena; el bug casi siempre
está en el que le da de comer.
Las dos últimas son las de las *deep operations* de las jerarquías de clases y conviene
señalar la asimetría: `do_copy()` sin `super` pierde datos en silencio;
`do_compare()` sin `&&` los compara de más, y devuelve *iguales* a dos objetos
que no lo son. La segunda es peor, porque apaga el scoreboard entero sin apagarlo.

---

## Apéndice · Las veinte trampas mudas

#### *Estímulo, ámbito y objections*

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| Los bins de borde **no se llenan nunca** | `dist` con `:=`: el peso va a **cada** valor del rango | medir el histograma **una vez**, con `:/` | Constrained random |
| El `randomize()` **no corre** con las asserts apagadas | `assert(x.randomize())` — `assert` es una directiva de simulación | `if (!x.randomize()) uvm_fatal(…)` | Constrained random |
| Bajo el override, **algunas** transactions son del tipo viejo | un `new()` donde iba `type_id::create()` | por la factory pasa lo que se crea con `create()` | Transactions |
| Los **dos agents** arrancan iguales | dos `set()` con ámbito `"*"`: el segundo pisa al primero | el ámbito es la **ruta** del que lee, con `*` al final | Agents · d6 |
| El agent arranca **activo** aunque pusiste `is_active` en el `config_db` | falta el `super.build_phase()`: el que lo lee es `uvm_agent` | o config object, o `super` — nunca media de cada una | Agents |
| La simulación **no termina nunca** | un `item_done()` que no se llamó | `+UVM_TIMEOUT=5ms` primero, el trace después | Agents |
| Termina en **t=0** y dice PASS | nadie levantó la objection alrededor de la sequence | `+UVM_OBJECTION_TRACE` | Sequences |

Note:
Las dos últimas son las únicas de las veinte que sí hacen ruido — una cuelga y
la otra termina raro — y están acá porque el ruido que hacen no señala al
culpable. Un cuelgue no dice qué se quedó esperando; un t=0 dice PASS, que es
peor que un error.
La del `assert(randomize())` merece decirse entera porque es la que más se copia
mal de internet: `assert` no es una función, es una directiva, y un simulador con
las asserts deshabilitadas **no ejecuta el argumento**. O sea que el randomize
directamente no pasa, la transaction se manda con los valores anteriores, y el
testbench sigue como si nada.
La del `new()` que se come el override es la más sutil del día 5, y conviene
mostrar el número: en `add_test`, dos de las transactions del testbench se
construían con `new()` y por lo tanto **no** eran `add_transaction`. Nadie se
enteró, porque el scoreboard comparaba bien igual.
Y una recomendación de cierre para el que estudia solo: leé este apéndice ahora y
otra vez el día que algo no ande. La primera vez no se entiende ninguna; la
segunda se entiende justo la que te está pasando.

---

## Apéndice · Las veinte trampas mudas

#### *Las cuatro de las assertions*

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| El log dice **PASS** y las properties no corrieron | falta `--assert` al compilar | el `cover property` en 0 es el único que avisa | Assertions |
| La property **pasa siempre** | el antecedente nunca ocurre, o la implicación es la que no va | un `cover property` por cada `assert property` | Assertions |
| **185 falsos positivos** y el DUT está sano | la muestreás con el flanco en el que se escribe | estímulo en `negedge`, respuesta del DUT en `posedge` | Assertions · d7 |
| Falsos positivos **al arrancar** cada test | falta el `disable iff (!reset_n)` | `default disable iff`, una vez, arriba de todo | Assertions |

- Las cuatro son de la misma familia que las quince de arriba, con un agravante:
  una assertion rota **se ve exactamente igual** que una que anda. No hay salida
  que mirar

Note:
Estas cuatro llegaron al apéndice con las assertions y son las únicas de la lista
donde el chequeo mismo es lo que falla — las otras quince son bugs del
testbench; éstas son bugs del que chequea el testbench. Por eso el antídoto es
siempre el mismo y por eso vale repetirlo hasta el cansancio: **un `cover
property` por cada `assert property`**.
La primera fila es la más barata de cometer en este flujo y conviene mostrarla en
vivo: sacar `--assert` del `run.sh` de `code/u8/assertions` deja la corrida con `+BUG=1`
en 0 `UVM_ERROR`. Las 183 fallas desaparecen sin que nada avise.
La tercera es la lección de la sección y la única de las veinte que no está en
ningún tutorial. El reflejo equivocado, cuando aparecen los falsos positivos, es
aflojar la property hasta que calle: ahí uno se queda sin chequeo y con la
sensación de haberlo arreglado. El reflejo correcto es preguntar en qué flanco
escribe el que estimula.

---

## Apéndice · Las veinte trampas mudas

#### *Y la que trae el clocking block*

| El síntoma | La causa | Cómo se ataja | Sección |
| --- | --- | --- | :-- |
| El scoreboard falla **una vez cada veinte** y el waveform se ve bien | media señal se lee por `cb.sig` y la otra media por `sig` | si entró al clocking block, **todo** el protocolo la lee por ahí | Interfaces y BFM |

- Es la única de las veinte que **la agrega una herramienta**: sin clocking
  block no existe. Mal usado es peor que no usarlo
- Dos nombres para el mismo cable, y difieren en un ciclo:
  `code/u2/clocking/mezcla.sv` imprime `3` y `4` en el mismo instante
- La variante del mismo error: esperar `@(posedge clk)` y después leer `cb.sig`.
  Si adoptás el clocking block, adoptás **también su evento**

Note:
Esta trampa cierra el apéndice y es la que mejor resume su tesis, porque el
síntoma es el peor de todos los de la lista: **intermitente**. Las otras
dieciocho fallan siempre o no fallan nunca; ésta falla cuando el dato cambia,
que es una de cada tantas corridas y justo la que no estás mirando.
Y tiene una vuelta que vale marcar en voz alta: es la única de la lista que
aparece *porque* usaste la herramienta que evita otro problema. El clocking
block saca la race del muestreo y mete la posibilidad de esta mezcla. No es un
argumento para no usarlo — es el argumento para usarlo **entero**, o no usarlo.
La regla en una línea, que es la de Dave Rich: si una señal pertenece al
timing contract de un clocking block, se accede siempre por ese contrato. El
material largo está en `docs/clocking-blocks.md`.
