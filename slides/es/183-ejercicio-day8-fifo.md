## Capstone 2 · Día 8

#### *El segundo final: una FIFO con backpressure*

`cd code/ejercicios/d8-fifo && cat spec.md`
<!-- .element: class="comando" -->

- Para el que ya entregó el APB. **El protocolo es más simple** —no hay
  direcciones, ni wait states, ni respuesta de error— y aun así es más difícil
- El del APB es un esclavo **sin memoria útil**: dirección y valor, y el
  scoreboard puede ser una tabla de cuatro filas. Una FIFO tiene **orden** y
  **ocupación**, y las dos hay que llevarlas
- El bug de `+BUG=1` no es de datos: `almost_full` se levanta **un lugar tarde**.
  Los datos siguen saliendo bien y en orden, así que un scoreboard que sólo
  compara `rd_data` pasa en verde
- La letra chica: las banderas describen el estado **antes** del flanco,
  `rd_data` llega **un ciclo tarde**, escribir con la FIFO llena **no es un
  error**, y una lectura simultánea **le hace lugar** a la escritura

Note:
Éste es el ejercicio que separa al que entendió del que copió el patrón, y el
mecanismo por el que separa está en el tercer bullet: el bug está en una
**salida de control**, no en el camino de datos. Un scoreboard que compara lo
que sale por `rd_data` cierra seis de las siete filas del plan y pasa en verde
con el DUT roto. Para verlo hay que predecir las banderas, y para predecir las
banderas hay que modelar la ocupación — o sea, escribir un modelo de referencia
con estado, que es lo que el primer capstone no podía pedir.
Vale decir por qué va segundo y no primero: el APB es el DUT que se cruza el
primer año, y el patrón tabla-direccion-valor es el correcto ahí. Éste enseña
cuándo ese patrón deja de servir, y esa lección no se entiende sin haber usado
el patrón antes.
La trampa que más cae es la del orden de actualización del modelo: primero mirar
si la lectura saca —eso libera un lugar— y recién después si la escritura entra.
Al revés, la escritura simultánea con la FIFO llena aparece como un dato perdido
que el DUT nunca perdió, y el alumno pasa una hora buscando el bug en el RTL.
Y la segunda: el `check_phase` que reclama datos que nunca salieron. Casi
siempre el test terminó un ciclo antes de tiempo, y es el `drain_time` del día 3
apareciendo donde nadie lo esperaba.
