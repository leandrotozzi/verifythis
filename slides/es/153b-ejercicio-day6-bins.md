## Ejercicio · Día 6 · 3 de 5

#### *Cerrar un bin*

`cd code/ejercicios/d6-bins && bash run.sh`
<!-- .element: class="comando" -->

- El test manda reset y **60 operaciones al azar**, y el reporte muestra el bin
  *"las dos patas en `FF`, multiplicando"* vacío
- Escribí la sequence de un item que lo cierre. Pero **pedila con
  `randomize() with {}`**, no asignando los campos
- Se corrige comparando la cobertura de antes y la de después: tiene que subir
- Es la **fila 3** del plan de verificación del día 1: la única de las doce cuya
  columna de estímulo dice *caso dirigido*

Note:
Es el ejercicio que le faltaba al curso, porque *coverage closure* aparece dos
veces como sustantivo y nunca como verbo. Acá el alumno hace el ciclo entero:
corre, mira qué bin quedó vacío, escribe tres líneas, vuelve a correr.
La trampa está puesta a propósito y es la de constrained random: `command_transaction`
tiene un `dist` sobre `A` y sobre `B`, y Verilator resuelve el `dist` eligiendo
un valor **antes** de mirar el `with`. Con el reparto activo, `with {A == 8'hFF}`
resuelve una de cada cuatro veces y el resto devuelve 0. El que no lea la pista
va a ver un ejercicio que a veces pasa y a veces no — que es exactamente el
síntoma que la sección describe.
El rodeo es `constraint_mode(0)`, y conviene defenderlo como decisión de diseño y
no como parche del simulador: un caso **dirigido** no quiere un reparto de
probabilidades, quiere un valor.
La semilla del `run.sh` está fijada. Sin fijarla, algunas corridas llenarían el
bin solas con las 60 al azar — y eso es el ejercicio siguiente.
