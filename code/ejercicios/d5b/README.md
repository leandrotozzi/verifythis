# Día 5 · segundo — medí tu `dist`

Sin UVM, sin DUT y sin testbench: una clase, un `dist` y un histograma. Es el
ejercicio corto del curso.

`histograma.sv` tiene una clase con un `rand byte unsigned A` y una constraint
que ya dice lo que queremos: **10 % en `00`, 80 % en el medio, 10 % en `FF`**.
Corré primero, antes de tocar nada:

```sh
bash run.sh
```

## Qué se pide

Que los tres casilleros den 10 / 80 / 10, con tolerancia de **±2 puntos** cada
uno.

Los pesos ya están escritos y son los correctos. **No cambies los números.** El
que está mal es otra cosa, y la salida de esa primera corrida te dice cuál.

Listo cuando `bash run.sh` imprime `EXERCISE OK`.

## Cómo se corre

```sh
bash run.sh              # con tu archivo
SOLUCION=1 bash run.sh   # con el de solucion/, para comparar
SEED=7 bash run.sh       # otra semilla: los números se mueven un poco
```

Tarda unos 20 segundos, y casi todo es el solver: Verilator resuelve cada
`randomize()` con constraints llamando a **z3** por afuera, así que 4000
randomizaciones son 4000 llamadas. Si te dice `Tried: $ z3 --in` y todos los
casilleros dan cero, te falta instalarlo (`apt install z3` / `brew install z3`).

## La pista, si la necesitás

La diferencia entre la solución y el archivo inicial es **un carácter**.

## Lo que practica

`:=` contra `:/` (21b), y la regla que ordena la sección: **no lo supongas,
medilo.** Una constraint mal escrita no falla, miente — no hay warning, no hay
error de compilación, y el testbench pasa igual. Lo único que la delata es la
cobertura que no sube, y eso se nota semanas después.

Vale la pena mirar los números con dos o tres semillas antes de darlo por
cerrado: con 4000 muestras el casillero del 10 % se mueve medio punto entre
corridas. Un porcentaje medido es una muestra, no la distribución.
