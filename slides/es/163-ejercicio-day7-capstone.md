## Capstone · Día 7

#### *El testbench entero, desde una hoja en blanco*

`cd code/ejercicios/d7-final && cat spec.md`
<!-- .element: class="comando" -->

- Los ejercicios anteriores daban un archivo con un agujero. Éste da un **DUT,
  una spec y nada más**
- El DUT no es la VTALU: es un **esclavo APB3** de cuatro registros. Tiene
  direcciones, dos fases por transferencia, un *wait state* y respuesta de error
- Se escribe todo: la interface con el protocolo, la transaction, el driver, el
  monitor, el agent, el scoreboard, el covergroup, las sequences y los tests
- El corrector va **por etapas**, y cada una imprime su `STAGE N OK`. Se puede
  terminar de a una — y conviene

Note:
Es la tarde del día 7 y es el ejercicio que justifica el curso entero. Vale
decirlo así de frontal: hasta acá el alumno completó estructura ajena, que es
exactamente lo que le van a pedir el primer día de un proyecto real — pero
nunca armó uno. La diferencia entre *"hice el curso"* y *"sé hacerlo"* es esta
tarde.
Si el grupo va corto de tiempo, la etapa 1 —el monitor— sola ya deja algo: es el
entregable que el apéndice del bus recomienda como primero, y se hace en media
hora.
El otro uso, para el que estudia solo: es el ejercicio que se puede mostrar en
una entrevista. Un testbench de UVM sobre un APB, escrito de cero, con su plan
de cobertura, es exactamente el ejemplo que piden.

---

## Capstone · Día 7

#### *El DUT: cuatro registros y la letra chica*

| Dir | Nombre | Acceso | Contenido |
|---|---|:--:|---|
| `0x00` | `CTRL` | RW | bit 0 = `EN` · bit 1 = `CLR`, **autoclear** |
| `0x04` | `SCRATCH` | RW | 32 bits, y **suma a `ACC` si `EN`** |
| `0x08` | `ACC` | RO | el acumulador |
| `0x0C` | `STATUS` | RO | bit 0 = `EN` · bit 1 = `OVF`, pegajoso |

{{code:code/ejercicios/d7-final/rtl/apb_regs.sv#handshake}}

- La lectura mete **un wait state**: el driver espera el handshake, no cuenta ciclos
- De `0x10` para arriba, `PSLVERR`. Escribir un RO, en cambio, **no** es error

Note:
Las cuatro trampas de la spec están puestas a propósito y las cuatro son de
spec mal leída, no de UVM: el wait state de la lectura, el `CLR` que nunca se lee
en 1, el registro de sólo lectura que se escribe sin dar error, y el acumulador
que sólo corre con `EN=1`. Son las cuatro que cuelgan al primer testbench, y
están juntas en una sección de `spec.md` que se llama *La letra chica* — en la
spec de verdad no van a estar juntas ni en una sección con ese nombre.
El `assign` del `PREADY` es la slide entera si hay que elegir una: dice que la
escritura no espera y la lectura sí, y de ahí sale el `do @(posedge PCLK); while
(!PREADY);` del driver. Un driver que dé por hecho que ACCESS dura un ciclo lee
`PRDATA` un ciclo antes de tiempo — y no falla siempre, que es lo peor que
puede pasar.

---

## Capstone · Día 7

#### *El orden: monitor, driver, scoreboard, cobertura*

- **1 · El monitor.** El `top.sv` trae **dos** esclavos: uno para tu testbench y
  otro que maneja un módulo de siempre, sin UVM. Un agent **pasivo** sobre ése, y
  a ver las ocho transferencias. Sin driver
- **2 · El driver.** El protocolo adentro de la interface, y una sequence
  dirigida que escriba y lea los cuatro registros
- **3 · El scoreboard.** El DUT modelado en software. El corrector lo corre dos
  veces: contra el DUT sano tiene que callarse, y con **`+BUG=1`** tiene que gritar
- **4 · La cobertura.** El covergroup con las nueve filas del plan de
  verificación de la spec: al menos 20 puntos, 90 % cubierto. Y **dos filas vienen
  vacías**
- **5 · Las properties.** El protocolo del APB adentro de `apb_if.sv`, con
  `--assert`. Con **`+BUG=2`** hay un bug que el scoreboard no puede ver

Note:
El orden no es un capricho del corrector: es el consejo de campo del apéndice
*De la VTALU a un bus real*. Lo primero que se escribe es el monitor, porque el
que arranca por el driver escribe estímulo que nadie está mirando y descubre a la
semana que su monitor no reconstruye. Por eso el `top.sv` viene con el segundo
esclavo: para que el monitor tenga algo que mirar **antes** de que exista el
driver.
La etapa 3 es la que más se discute y la que más rinde: un scoreboard que nunca
vio un error no está probado. `+BUG=1` le saca al DUT el gate de `CTRL.EN`, así
que el acumulador suma siempre. Un modelo que no haya modelado `EN` pasa las dos
corridas y el corrector lo caza — que es exactamente lo que haría una regresión
con un test de mutación.
Y una pista de forma para la etapa 3, que ahorra una reescritura: el APB contesta
**en orden y de a una**, así que una cola alcanza y el scoreboard puede comparar
en el momento. Conviene anotar esa suposición en el plan igual que cualquier
otra, porque es la primera que se cae cuando el DUT deja de ser un esclavo
simple: ahí el patrón es la tabla indexada por ID de los analysis ports.
Y la etapa 4 cierra el círculo del día 6: el covergroup no se inventa, se copia
de la tabla del plan de verificación. Si un bin queda en cero, hay una fila del
plan que no se verificó — por más que el scoreboard esté en verde.

---

## Capstone · Día 7

#### *La etapa 5: el bug que el scoreboard no puede ver*

```systemverilog
// En apb_if.sv, con las señales. El payload no se mueve hasta que termina
property p_payload_estable;
   @(posedge PCLK) PSEL && !(PENABLE && PREADY) |=> $stable({PADDR, PWRITE, PWDATA});
endproperty

a_payload_estable : assert property (p_payload_estable)
   else `uvm_error("SVA", $sformatf("%m: el payload se movió antes del PREADY"))
```

- `+BUG=2` le hace al módulo de siempre lo que `d7-sva` le hacía al tester
  heredado: **mover `PADDR` en el medio de ACCESS**
- El DUT contesta en la dirección nueva, el monitor reconstruye **ocho
  transferencias impecables**, y el scoreboard no tiene nada que comparar mal
- Medido: **8 `UVM_ERROR [SVA]`** y las mismas 8 transferencias en el log del
  monitor. La única que se entera es la assertion
- Y las filas **8 y 9** del plan vienen vacías: *back to back* y dirección no
  alineada. Los bins se llaman `back_to_back` y `unaligned`

Note:
Ésta es la etapa que hace que el capstone integre el día entero y no la mitad. El
argumento *"el scoreboard chequea qué, la assertion chequea cómo"* venía desde el
día 1 y se demostraba sobre la VTALU; acá se demuestra sobre un bus con
direcciones, dos fases y wait state, que es donde el alumno lo va a necesitar.
Vale hacer la cuenta en voz alta, porque es lo que convence: con `+BUG=2` el
módulo cambia la dirección después del SETUP. El DUT es combinacional en la
decodificación, así que atiende la dirección nueva. El monitor muestrea en el
flanco del handshake, así que reconstruye la transferencia con la dirección
nueva. Monitor y DUT coinciden — **no hay nada que el scoreboard pueda comparar
mal**. El único que sabe que la dirección se movió es el que estaba mirando el
cable en cada flanco.
Las dos filas vacías son la otra mitad del ejercicio y son deliberadamente
incómodas: las dos cosas que miden están prometidas en la spec, cada una en una
línea suelta, y ninguna de las siete filas de arriba las mide. La fila 9 además
cuelga al scoreboard que decodifica con la dirección entera — `PADDR[1:0]` se
ignora, así que `0x06` **es** el `SCRATCH`.
Y una trampa que vale la pena contar porque el propio curso se la comió: la
lectura obvia de *"`PSLVERR` es válido junto con `PREADY`"* es
`PSLVERR |-> PREADY`, y es **falsa** en este DUT. `PSLVERR` es combinacional, así
que en una lectura no mapeada ya está alto durante el wait state. Escrita como
assertion dispara sobre el DUT sano. Esa regla es un `cover`, no un `assert`.

