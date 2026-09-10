## Callbacks

#### *El tercer gancho*

- El día 1 prometimos **tres** formas de escribir un test nuevo sin tocar el env:
  **constraints**, **factory override** y **callbacks**. Van dos
- Las tres son la misma idea a distinta altura: la constraint cambia **valores**,
  el override cambia **una clase entera**, el callback cambia **qué hace una
  clase en un punto**
- El caso que las separa: te dan un agent de VIP —de otro equipo, o comprado— y
  necesitás que el driver mande un dato roto **una vez cada tanto**
- Con override tenés que reescribir el driver entero para cambiar una línea. Con
  un callback enganchás esa línea y nada más
- Y hay una diferencia que no es de estilo: **los callbacks se apilan**. El
  override elige *una* clase; los callbacks corren **todos**, en orden

Note:
Esta media sección existe porque la unidad 1 promete tres ganchos, y sin ella el
curso entrega dos. Quince minutos alcanzan: la mecánica es chica y lo que hay que
dejar es el criterio de cuándo se usa.
El criterio, dicho en una línea: **override cuando cambia el qué, callback
cuando cambia el cuándo**. Si la clase nueva es distinta de la vieja en varios
métodos, es un override. Si es la misma clase con un agregado en un punto, es un
callback — y sobre todo si la clase original no es tuya y no la podés tocar.
La palabra clave de todo esto es **VIP**. En un proyecto real la mitad de los
agents vienen de afuera, con su licencia y su soporte, y editarlos no es una
opción: la próxima versión te pisa el cambio. El callback es el punto de
extensión que el que escribió el VIP dejó a propósito.
Y el que apilen es lo que hace que dos ingenieros puedan enganchar cosas
distintas en el mismo driver sin pisarse. Con overrides, el segundo gana.

---

## Callbacks

#### *El gancho: una clase, un método virtual vacío*

{{code:code/u7/callbacks/tb_classes/driver_callback.svh#driver_callback}}

- Un `uvm_callback` **no es un component**: no está en el árbol, no tiene fases y
  no aparece en `print_topology()` — igual que una sequence
- El método base está **vacío a propósito**: sin nadie registrado, el testbench
  corre exactamente como antes
- Es una `task` y no una `function` porque un callback de *delay* tiene que
  poder consumir tiempo. Uno que sólo edita la transaction podría ser función

Note:
Vale detenerse en que es una clase normal, que extiende `uvm_callback`, que
extiende `uvm_object`. No hay magia: lo único que hace `uvm_callback` es darle
un lugar en el pool que UVM mantiene por instancia de componente.
El `typedef class driver;` de arriba del archivo es la parte aburrida y
necesaria: el callback recibe el driver, y el driver registra el callback, así
que uno de los dos tiene que declararse adelantado. En un testbench de verdad
esto vive en su propio archivo por eso mismo.
Si alguien pregunta por qué el método base está vacío en vez de ser abstracto:
porque `uvm_do_callbacks` recorre **la cola entera**, y una cola vacía tiene que
ser legal. La clase base vacía es la que hace que "sin callbacks" sea el caso
normal y no una excepción.

---

## Callbacks

#### *Dos líneas en el driver, y ninguna más*

{{code:code/u7/callbacks/tb_classes/driver.svh#register-cb}}

{{code:code/u7/callbacks/tb_classes/driver.svh#run_phase}}

- `` `uvm_register_cb `` declara el par tipo/callback. Sin él el `add()` engancha
  igual y el callback **corre** — con un `UVM_WARNING CBUNREG` perdido en el log,
  y sin el chequeo de tipos ni el `add_by_name`
- `` `uvm_do_callbacks `` es el punto de extensión: recorre la cola de **esa
  instancia** de driver, en orden

Note:
El diff contra el driver de la sección Agents es exactamente de dos líneas, y
conviene mostrarlo con `diff` en vivo: `diff code/u7/agents/tb_classes/driver.svh
code/u7/callbacks/tb_classes/driver.svh`. Todo lo demás —el `get_next_item`, el
`send_op`, el `item_done`— está igual.
El modo de falla del `uvm_register_cb` que falta no es el que uno espera, y vale
contarlo con la fuente en la mano porque la mitad de los tutoriales lo dice al
revés: `uvm_callback.svh:745` reporta un `UVM_WARNING CBUNREG` y **sigue de
largo** — el `add()` mete el callback en `m_base_inst.m_pool` igual (`:781-785`),
y `` `uvm_do_callbacks `` lee ese pool sin consultar el registro (`:964-1006`).
O sea: sin la macro el callback corre, y lo que perdés es el chequeo de tipos y
el `add_by_name` por tipo derivado. Es peor que un error: es un warning entre mil
líneas, y el testbench queda fuera del contrato sin que se note.
Por eso el `run.sh` del ejemplo no chequea la macro sino el efecto: cuenta cuántas
veces se ejecutó el callback y falla si es cero. Un ejemplo que "pasa" sin haber
inyectado nada no prueba nada, venga de donde venga el desenganche.
Dónde poner el `` `uvm_do_callbacks `` es la decisión de diseño real, y es la
misma que toma el que escribe un VIP: cada punto de gancho es una promesa de
compatibilidad hacia adelante. Por eso los VIP tienen tres o cuatro, no treinta.

---

## Callbacks

#### *Ponerlos: el test, y nada más que el test*

{{code:code/u7/callbacks/tb_classes/inject_test.svh#hooking-the-cb}}

- El test **no toca** el env, ni el agent, ni el driver, ni la sequence. Igual
  que el override, un nivel más abajo
- `end_of_elaboration_phase` y no `build_phase`: el driver es nieto del env, y
  cuando el `build_phase` del test termina **todavía no existe**
- Los dos callbacks van sobre la **misma** instancia y corren **los dos**, en el
  orden en que se agregaron

`bash run.sh +CALLBACK_TRACE` imprime la cola del driver
<!-- .element: class="comando" -->

Note:
La trampa de fases es la que se lleva la tarde de alguien: `uvm_callbacks::add`
necesita el handle del componente, y el árbol se construye de arriba hacia
abajo. En `build_phase` del test, `env_h` existe —lo acaba de crear— pero
`env_h.clase_agent_h` es `null`. `end_of_elaboration_phase` corre con el árbol
entero armado, que es justo lo que hace falta.
La alternativa que a veces se ve es `add_by_name("*driver_h", cb, this)`, con un
patrón en vez de un handle. Sirve cuando no querés atravesar la jerarquía, y
tiene el mismo problema de fase.
Y el agent pasivo no aparece en ninguna de las dos líneas por una razón obvia
cuando se dice: no tiene driver. Los callbacks se cuelgan de instancias, no de
tipos, así que "el driver del agent activo" es una dirección concreta en el
árbol.

---

## Callbacks

#### *El bit dado vuelta que el scoreboard no ve*

`cd code/u7/callbacks && bash run.sh`
<!-- .element: class="comando" -->

- El `flip_bit_cb` da vuelta un bit de `A` una de cada ocho transactions. El
  scoreboard **no dice nada**, y las dos corridas cierran en 0 `UVM_ERROR`
- No es un agujero del corrector: es la prueba de que **el monitor mira el
  cable**, no lo que el driver creía que iba a mandar
- Un monitor que reconstruyera la transaction desde el driver —o que la copiara
  del sequencer— habría dado *PASS* sobre un dato que el DUT nunca vio
- Lo que sí se ve del `jitter_cb` es el **tiempo**: mismo estímulo, más ciclos

| El gancho | Cambia | Cuántos a la vez |
| --- | --- | :--: |
| **Constraint** | los valores | los que quieras |
| **Factory override** | la clase entera | **uno** |
| **Callback** | qué hace una clase en un punto | los que quieras |

Note:
Ésta es la slide de la media sección, y el ejercicio de pensar vale más que el
código: *"si inyecto un error y el scoreboard no grita, ¿el scoreboard está mal?"*
Dejar que el grupo se pelee un minuto antes de contestar.
La respuesta es que no, y es una de las cosas más importantes del curso: el
scoreboard predice a partir de lo que el **monitor** vio en el bus. Si el driver
manda `A^1`, el DUT calcula con `A^1`, el monitor ve `A^1` y la predicción da
`A^1`. Todo consistente. El único testbench al que este callback lo rompería es
uno con un monitor que no mire las señales — y ese testbench está mal desde antes
de que existiera el callback.
De ahí sale la regla que ya vimos en Agents y que ahora tiene una demostración:
**el monitor mira el cable, siempre**. Un callback de inyección es, además de una
herramienta, el test más barato que existe para saber si tu monitor lo hace.
Para inyectar un error que el scoreboard **sí** tenga que cazar, hay que romper
el DUT, no el estímulo — que es exactamente lo que hace el `+BUG=1` del capstone.
