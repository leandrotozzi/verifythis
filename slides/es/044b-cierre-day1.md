## Seis de cada siete, otra vez

#### *Cierre del día*

- La regresión que mandó el bug a fabricar dijo `PASS`. Hoy tenés tres formas
  de saber si ese `PASS` valía algo, y las tres son columnas de una tabla
- **¿Qué había que probar?** Un plan: una fila por escenario, escrito antes que
  el testbench, desde la spec
- **¿Quién dijo que estuvo bien?** Un scoreboard que predice y compara — y que
  viste fallar con un bug adentro
- **¿Cuánto del plan pasó?** Un `covergroup` con un bin por fila, y el reporte
  por bin, no el porcentaje
- Las tres ya piden operaciones en vez de mover cables: eso fue la BFM. Lo que
  todavía no se puede es **cambiar el estímulo sin editar el archivo**. Mañana
  es eso

Note:
Treinta segundos, y son los que cierran el arco del día: la primera slide hizo
una pregunta y ésta la contesta con lo que el alumno escribió, no con teoría.
Si el grupo está cansado, volver a poner la slide del 14 % un segundo antes de
ésta: la pregunta era *"¿cómo sabés que verificaste?"*, y la respuesta corta es
*"tengo el plan, lo vi fallar y sé qué bin falta"*.
Lo que no hay que prometer de más: esto no evita el respin. Lo que evita es
mandar a fabricar un `PASS` que nadie sabía qué significaba.
El último bullet es el que el día 2 abre con *"Ayer quedó"*: un tester que sólo
multiplica es copiar el archivo y borrarle cinco líneas. Ése es el problema que
las clases resuelven, y conviene dejarlo como problema y no como promesa.
