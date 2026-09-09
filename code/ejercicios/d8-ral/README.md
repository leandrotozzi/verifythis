# Día 8 · RAL — modelar el mapa de registros

Es lo primero que te piden en un proyecto con registros, y es literalmente esto:
te dan la tabla de la spec y devolvés el modelo.

El DUT es el del capstone —el esclavo APB de cuatro registros— y el testbench
también: la interface, la transaction, el driver, el monitor y el agent salen de
[`d7-final/solucion/`](../d7-final/solucion/), así que el ejercicio corre aunque
todavía no hayas terminado el capstone. El adapter, el predictor y los tres
tests salen de [`code/u9/ral/`](../../u9/ral/) y no se tocan.

**De todo eso, lo único que escribís es el modelo de registros.**

```sh
bash run.sh
```

## Qué se pide

**`apb_reg_block.svh`** — la tabla de
[`../d7-final/spec.md`](../d7-final/spec.md), sección *El mapa de registros*,
escrita como modelo de UVM. Cuatro registros, seis campos, cuatro direcciones.

| Dir | Nombre | Acceso | Campos |
|---|---|:--:|---|
| `0x00` | `CTRL` | RW | `EN` bit 0 · `CLR` bit 1, **autoclear** |
| `0x04` | `SCRATCH` | RW | 32 bits |
| `0x08` | `ACC` | RO | 32 bits, y **cambia solo** |
| `0x0C` | `STATUS` | RO | `EN` bit 0 · `OVF` bit 1, y **cambian solos** |

El corrector va por etapas y cada una imprime su `STAGE N OK`:

1. **El mapa.** Sin simular nada: el modelo se imprime y se compara con la
   tabla. Un offset o un ancho mal se ven acá.
2. **Los accesos.** `uvm_reg_hw_reset_seq` y `uvm_reg_bit_bash_seq`, que salen de
   `uvm-core` y no saben nada de este DUT: leen tu modelo y generan el estímulo y
   el chequeo. Son **los tests que no escribiste**, y es el argumento entero a
   favor de RAL.
3. **Lo que el modelo no puede predecir.** `ACC` y `STATUS` tienen dirección pero
   no son registros: su valor lo produce una escritura a *otra* dirección. Un
   modelo que no diga eso da falsos positivos, y el falso positivo es del modelo,
   no del DUT.

Listo cuando `bash run.sh` imprime las tres etapas y termina con `EXERCISE OK`.

## Cómo se corre

```sh
bash run.sh              # con tu archivo
SOLUCION=1 bash run.sh   # con el de solucion/, para comparar
```

El modelo se imprime solo, y es lo primero que conviene mirar:

```sh
bash run.sh 2>&1 | grep MAPA
```

## Cuánto tarda

Compila UVM entera, incluido `uvm-core/src/reg`. Medido con Verilator 5.052:

| | 12 cores | 2 cores (Codespaces gratis) |
|---|---|---|
| la primera vez | ~1 min 30 | ~4 min |
| las siguientes, con `ccache` | ~15 s | ~15 s |

## Pistas, en orden de utilidad

- **`CLR` no es RW.** La spec dice *"escribir un 1 pone `ACC` y `OVF` en cero, y
  el bit siempre se lee 0"*. El bit **se lee**, así que el acceso es de la familia
  que borra en la escritura y devuelve ese cero en la lectura. Si le ponés `RW`,
  la etapa 1 pasa y la **etapa 2** te lo dice con el número del bit — que es
  exactamente lo que hace bien `bit_bash`.
- **Y no es `WO` ni `WOC`.** Cualquier acceso que arranque con `WO` saca al campo
  de `bit_bash` (`uvm_reg_bit_bash_seq.svh:129-135`, *"Ignore Write-only fields"*)
  y de la máscara de `do_check` (`uvm_reg.svh:2782-2788`). Las dos etapas pasan en
  verde **sin haber mirado el bit**: es la trampa muda de RAL.
- El argumento `volatile` de `configure()` no cambia la predicción: es una
  declaración de intención, y UVM la usa para avisarte con un `UVM_WARNING`
  cuando leés el espejo de un campo que cambia por atrás.
- `set_compare(UVM_NO_CHECK)` va sobre el **campo**, no sobre el registro, y
  apaga sólo el `mirror(UVM_CHECK)`. La lectura sigue actualizando el espejo:
  una lectura *es* una predicción.
- `build()` de un `uvm_reg_block` **no es un `build_phase`**. Un block es un
  `uvm_object`: nadie lo llama por vos. Lo llama el test, una línea después del
  `create()`.
- Si `bit_bash` no reporta nada sobre un registro, fijate si lo agregaste al
  mapa. Un registro que no está en ningún mapa no existe para la sequence.

## Lo que practica

La sección de RAL entera, que es corta a propósito: el modelo, el
`uvm_reg_field` y su cadena de accesos, `add_reg` y el mapa. Y una idea que no
es de UVM: **la diferencia entre un registro y una dirección**.
