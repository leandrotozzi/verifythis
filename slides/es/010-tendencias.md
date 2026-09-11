## Tendencias

#### *Por qué vuelven: lo que hay adentro de un chip hoy*

![Qué tienen adentro los IC/ASIC de 2024: relojes asincrónicos, procesador embebido, seguridad, IA, RISC-V y safety](res/trends/complejidad.svg)
<!-- .element: class="grande" -->

Note:
Es la primera mitad de la respuesta a *por qué vuelven*: adentro hay dos
relojes asincrónicos en casi todos, un procesador en cinco de cada seis y un
acelerador de IA en más de la mitad. No es que se verifique peor que hace
veinte años; es que hay mucho más para verificar, y la pregunta de la primera
slide es más difícil de contestar que nunca.

---

## Tendencias

#### *Verificar no es una etapa, es la mitad del trabajo*

![Del tiempo del diseñador, 49 % va a verificación; del tiempo del verificador, 47 % va a debug](res/trends/esfuerzo.svg)
<!-- .element: class="grande" -->

Note:
Acá está el argumento de por qué existe este curso: el esfuerzo de verificación
ya empató al de diseño. Verificar no es el paso final antes del tape-out: es la
mitad del proyecto, con su propio equipo y su propio lenguaje.
El 47 % de abajo se siembra hoy y se cobra dos veces: en el segundo
ejercicio de esta tarde, cuando el log diga `FAILED` y nada más, y en la
sección de reporting del día 3, que es donde el log aprende a decir por qué.

---

## Tendencias

#### *Y se verifica, sobre todo, con UVM*

![Con qué se verifica en 2024: UVM al 80 % en IC/ASIC y al 50 % en FPGA](res/trends/metodologia.svg)
<!-- .element: class="grande" -->

Note:
Ésta contesta *con qué*: ocho de cada diez proyectos de ASIC verifican con
UVM, y la mitad de los de FPGA. Lo que sigue —el chiste del COBOL y la
introducción— es qué es ese UVM y por qué no asusta. Y una cosa que conviene
dejar dicha ahora: UVM no contesta la pregunta de la primera slide. La contesta
el testbench; UVM es la forma de escribirlo para que el de al lado lo reconozca.

---

## ¿SystemVerilog es el *COBOL* de la electrónica?

| Lenguaje | Reserved Keywords |
| --- | --- |
| ANSI COBOL 85 | 357 |
| SystemVerilog | 248 |
| VHDL 2008 | 115 |
| Verilog 95 | 102 |
| C# | 102 |
| C++ 20 | 92 |
| Python 3 | 35 |

> *"* No academic computer scientists participated in the design of COBOL;
>  all of those on the committee came from commerce or government"* ¿Parecido no?

Note:
Es un chiste con moraleja: SystemVerilog tiene 248 keywords —las del Annex B
del IEEE 1800-2017— y nadie las usa todas. En el curso vamos a usar unas
treinta. Con UVM pasa lo mismo: la librería es enorme y con seis o siete clases
se arma un testbench completo.
Sirve para bajarle la ansiedad al que llega asustado por el tamaño de UVM.
Y es el puente a la sección que sigue: ocho de cada diez verifican con UVM,
UVM está escrito en este lenguaje, y en los días 1 y 2 se escribe a mano todo lo
que UVM después va a dar hecho. Con treinta keywords alcanza.
