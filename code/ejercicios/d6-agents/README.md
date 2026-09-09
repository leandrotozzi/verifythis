# Día 6 — el agent que sólo mira

El testbench es el de los agents, pero recortado: hay **un solo agent**, el que
maneja `clase_bfm`. La segunda VTALU la maneja `vtalu_tester_module` y nadie la
está mirando.

## Qué se pide

1. **`vtalu_agent.svh`** — hoy el `build_phase` construye el sequencer y el
   driver **siempre**, así que `is_active` no sirve para nada. Hacé que se
   construyan sólo cuando el agent es activo. El `connect_phase` también.

2. **`env.svh`** — agregá el segundo agent:
   - su `vtalu_agent_config`, con `modulo_bfm` y `UVM_PASSIVE`
   - el `set()` en el `uvm_config_db`, **con el ámbito que le corresponde**
   - el agent, un `scoreboard` y un `coverage` propios
   - las dos conexiones, contra los analysis ports **del agent**

   Los nombres importan: el corrector busca `modulo_agent_h` y
   `modulo_scoreboard_h`, igual que los `clase_*` que ya están.

Listo cuando `bash run.sh` imprime `EXERCISE OK`.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

Para ver el árbol de componentes con tus ojos y no con los del corrector:

```sh
bash ../../u7/agents/run.sh +TOPOLOGY
```

## Cuánto tarda

Este ejercicio compila UVM entera. Medido con Verilator 5.052:

| | 12 cores | 2 cores (Codespaces gratis) |
|---|---|---|
| la primera vez | ~1 min 30 | ~4 min |
| las siguientes, con `ccache` | ~15 s | ~15 s |

El hit de `ccache` es copiar un archivo, así que la segunda compilación tarda lo
mismo en cualquier máquina. Instalalo antes de empezar —el `run.sh` lo detecta
solo— o usá Codespaces, que ya lo trae.

## Pistas, en orden de utilidad

- El ámbito del `set()` es la **ruta** del componente que va a leer, no un
  nombre libre. Con `"*"` en las dos líneas, la segunda pisa a la primera y los
  dos agents arrancan iguales.
- El asterisco del final importa: `"modulo_agent_h*"` alcanza también al driver
  y a los monitores de adentro. Sin él, el agent encuentra su config y sus hijos
  no.
- Si el `connect_phase` revienta con un `null`, es porque el agent pasivo no
  tiene driver y le estás pidiendo el `seq_item_port` igual.

## Lo que practica

`is_active` y el ámbito del `uvm_config_db`, analysis ports, y la
idea de fondo de la sección: **el agent es la unidad que se instancia una vez por
interface**. La segunda VTALU no necesita un testbench nuevo. Necesita una
línea más.
