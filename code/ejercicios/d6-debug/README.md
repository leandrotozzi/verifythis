# Día 6 — tres bugs plantados, y ninguno se parece al otro

Los otros ejercicios te dan un archivo con un agujero y te dicen qué escribir.
Éste te da un testbench **que ya está escrito** y no anda, y no te dice dónde.

Es el ejercicio que se parece al primer mes de trabajo.

El testbench es el entero de la sección de sequences. Tres de sus archivos se
copiaron acá con **un bug cada uno**, y los tres fallan de forma distinta:

| | Archivo | Cómo se manifiesta |
|:--:|---|---|
| **1** | `driver.svh` | **cuelga**: el log se corta y la simulación muere en `[PH_TIMEOUT]` |
| **2** | `default_seq_test.svh` | **termina en `t=0`** y dice PASS, sin haber mandado nada |
| **3** | `random_sequence.svh` | **miente en verde**: `add_test` pasa, la cobertura sube, y el estímulo no es el que dice |

## Qué se pide

Arreglar los tres. El corrector te dice **cuál** de los tres sigue roto y en qué
se nota; cuál es la línea, es el ejercicio.

Listo cuando `bash run.sh` imprime las tres etapas y termina con `EXERCISE OK`.

## Por dónde se empieza

La caja de herramientas del apéndice de debug es exactamente para esto, y la
tabla *"cuál usar según el síntoma"* tiene los tres:

- **Cuelga** → `+UVM_TIMEOUT=2000000,YES` para no esperar al infinito, y después
  `+UVM_OBJECTION_TRACE` para ver quién quedó agarrado. El `run.sh` ya pasa el
  timeout: sin techo, un testbench colgado cuelga también al CI.
- **Termina en t=0** → `+UVM_OBJECTION_TRACE`. Si nadie la levanta, la fase
  termina enseguida y **no hay error**: no hay nada de qué quejarse.
- **Miente en verde** → `+TOPOLOGY` es el reflejo correcto… y acá **no alcanza**,
  porque lo que se construyó mal es un `uvm_object` y el árbol sólo muestra
  `uvm_component`. La herramienta que sirve es leer el log del
  `command_monitor` con `+UVM_VERBOSITY=UVM_HIGH` y mirar **qué salió al bus**.

Los tres bugs están catalogados en el apéndice de trampas mudas. Si te trabás,
está permitido leerlo: la lista de trampas existe justamente para que la segunda
vez tardes cinco minutos.

## Lo que NO hay que hacer

Los tres archivos son los del curso con una línea cambiada cada uno. No hace
falta reescribir nada, ni agregar clases, ni tocar `tb.f`. Si tu arreglo tiene
más de tres líneas en total, estás resolviendo otro problema.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

## Cuánto tarda

Compila UVM entera, como el resto de los ejercicios del día 6:

| | 12 cores | 2 cores (Codespaces gratis) |
|---|---|---|
| la primera vez | ~2 min | ~5 min |
| las siguientes, con `ccache` | ~20 s | ~20 s |

## Lo que practica

Debug, que es lo que un verificador hace la mayor parte del día y lo que ningún
otro ejercicio del curso practica solo. Y una idea que ordena todo lo demás:
**los tres modos de falla de un testbench de UVM no se parecen entre sí**. Uno
cuelga y se nota enseguida; los otros dos pasan en verde, y ésos son los que
cuestan semanas.
