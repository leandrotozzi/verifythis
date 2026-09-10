## Ejercicio · Día 5 · 2 de 3

#### *Medí tu `dist`*

`cd code/ejercicios/d5b && bash run.sh`
<!-- .element: class="comando" -->

- Una clase, un `dist` y un histograma. Sin UVM, sin DUT, sin testbench
- Los pesos **ya dicen 10, 80 y 10**. Corré primero, y mirá lo que sale
- Se pide que los tres casilleros den 10 / 80 / 10 con ±2 puntos de tolerancia
- La diferencia entre lo que hay y la solución es **un carácter**

Note:
Es el ejercicio corto del curso y el que hay que dejar para el que se quedó sin
tiempo: compila y corre solo, sin UVM.
La gracia está en el orden: se corre **antes** de tocar nada. El archivo dice 10,
80 y 10, la salida dice 0,1 % en los bordes, y ahí aparece sola la pregunta de la
sección — si los números están bien, ¿qué está mal? Está mal el operador, y no
hay warning que lo diga.
Conviene pedirles que lo corran dos o tres veces con `SEED=` distintas antes de
darlo por cerrado: con 4000 muestras el casillero del 10 % se mueve un punto
largo entre corridas, entre 9 y 11 — por eso el corrector acepta ±2. Un porcentaje medido es una muestra, no la distribución — que es
la otra mitad de la regla de la sección.
Detalle de infraestructura que vale mencionar si alguien pregunta por qué tarda
veinte segundos un programa que no tiene DUT: Verilator resuelve cada
`randomize()` con constraints llamando a **z3** por afuera, así que son 4000
llamadas a un proceso externo. Y si no lo tienen instalado, `randomize()`
devuelve 0 y todos los casilleros dan cero — otra que no rompe, miente.
