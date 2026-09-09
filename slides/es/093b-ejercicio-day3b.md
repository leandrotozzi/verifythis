## Ejercicio · Día 3 · 2 de 2

#### *El `uvm_error` que no dice nada*

`cd code/ejercicios/d3b && bash run.sh`
<!-- .element: class="comando" -->

- El scoreboard está **bien** —atrapa todos los errores— y cuando falla dice
  `FAILED` y nada más. Es la línea con la que arrancó el día 1
- Que el `uvm_error` diga **cuál** falló: `A`, `B`, la operación, el resultado
  del DUT y el que predijiste
- Y que el que **pasa** también se imprima, con `UVM_HIGH`, para que no aparezca
  en el log de todos los días
- El corrector mira el mismo bus que vos y sabe cuál fue la primera que falló

Note:
Es el ejercicio corto del día 3 y cierra el arco que abrió la primera slide del
curso: ahí el alumno era el que leía el `FAILED`, acá es el que lo escribe.
Diez minutos de tipeo, y el punto no está en el `$sformatf`.
El punto está en el segundo pedido, que es el que sorprende: el `PASS` **también**
se escribe. La reacción típica es *"¿para qué quiero mil líneas de PASS?"*, y la
respuesta es que no las querés hoy: las querés el día que falla la operación 700
y necesitás saber qué pasó en la 699. Por eso se escribe **y** se esconde detrás
de `UVM_HIGH`. Ésa es la diferencia entre severidad y verbosidad, dicha con las
manos.
El corrector corre el mismo testbench tres veces, y conviene contarlo porque es
la forma en que se prueba un log: una con el DUT roto —`+VTALU_BUG`— para que el
error dispare y se pueda leer, una con la verbosidad de siempre para exigir que
el `PASS` **no** esté, y una con `+UVM_VERBOSITY=UVM_HIGH` para exigir que esté
una vez por comparación. Un mensaje que no se probó de las tres formas es un
mensaje que va a mentir en la regresión de la noche.
