## Ejercicio · Día 7 · 2 de 2

#### *El módulo heredado viola el protocolo y nadie lo sabía*

`cd code/ejercicios/d7-sva && bash run.sh`
<!-- .element: class="comando" -->

- El "tester del jefe" de los agents maneja su VTALU **a mano** para la
  multiplicación, y va dejando listo el operando de la próxima mientras espera
  `done`. Está en producción hace años
- El scoreboard compara mil operaciones y no encuentra una sola diferencia:
  el multiplicador latcheó `A` y `B` en el primer flanco. **El bug no es de datos**
- Escribí la property que sí lo ve. Las dos de `done` ya están, de molde
- El corrector pide tres cosas: que dispare sobre `modulo_bfm`, que **no** dispare
  ni una vez sobre `clase_bfm`, y que el scoreboard siga en verde

Note:
El ejercicio se resuelve con una property de tres líneas, pero la segunda
condición del corrector es la que enseña: quien la muestree en `posedge` va a ver
falsos positivos sobre la interface que **sí** respeta el protocolo, y el mensaje
lo va a mandar a mirar el flanco. Es la slide de los dos relojes, cobrada.
Vale insistir en la pista del `cover property` para el que se queda sin disparos:
el reflejo natural es aflojar la property hasta que haga algo, y es el reflejo
equivocado. El cover en 0 distingue *"la property está mal escrita"* de *"el
antecedente no ocurre"*, y son dos problemas distintos.
Y la moraleja que se lleva más allá del ejercicio: la property no la escribió
nadie pensando en el módulo del jefe. Vive en la interface, y por eso chequea a
todo el que la use — incluido el código que se escribió cinco años antes de que
existiera este testbench.
