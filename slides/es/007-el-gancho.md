## Seis de cada siete

#### *Y el bug que llegó al silicio pasó una regresión en verde*

![Cómo terminan los proyectos IC/ASIC en 2024: 14 % acierta el primer silicio y 75 % llega atrasado](res/trends/resultado.svg)
<!-- .element: class="grande" -->

- El **14 %** de los proyectos acierta el primer silicio. Seis de cada siete
  vuelven a la fábrica, y es el peor valor en veinte años de encuesta
- Cada bug funcional que llegó al silicio pasó antes por un testbench. Ese
  testbench corrió, terminó, y **dijo que estaba bien**
- Nadie manda a fabricar con un `FAILED` en el log. Se manda con un `PASS`
- La pregunta de hoy es una sola: **¿cómo sabés que verificaste?** Y *"corrí
  muchos tests"* no es una respuesta

Note:
Es la primera slide con contenido del curso a propósito: antes de explicar qué
es UVM y antes de cualquier otro gráfico, una pregunta que el alumno no puede
contestar todavía.
El número es del Wilson Research Group 2024 y no es una impresión: sólo el 14 %
sale bien en el primer silicio, o sea que seis de cada siete necesitan al menos
un respin, y es el peor valor en veinte años de encuesta. Preguntar quién hizo
un tape-out y cómo salió engancha más que el gráfico. Si preguntan de dónde
salen los datos: `res/trends/data.json`, y las figuras se regeneran con
`make figs`.
La honestidad que hay que decir en voz alta: no todos los respins son
funcionales —hay de timing, de analógica, de una spec que cambió tarde—. Pero
el que lo es pasó por una regresión que dijo `PASS`, porque si hubiera dicho
`FAILED` no se fabricaba. Ése es el enemigo del día, y no es el verificador ni
su testbench: es un `PASS` que nadie sabía qué significaba.
La pregunta del último bullet se tira al grupo y **no** se contesta. Las
respuestas que van a salir son *"cobertura al 100 %"*, *"corrí mil
operaciones"* y *"no falló nada"*, y las tres vuelven hoy mismo: la primera es
la sección de cobertura, la segunda es el plan, y la tercera es la que más
duele, porque *no falló nada* es exactamente lo que dijo la regresión del
respin. La respuesta corta llega en el testbench convencional, cuando le
metamos un bug al DUT a propósito; la larga es el día entero, y la última
slide del día vuelve a esta pregunta con lo que el alumno escribió.
