## Tendencias

#### *El primer silicio casi nunca sale bien*

![Porcentaje de proyectos que llegan al primer silicio sin errores, por año](res/trends/resultado.svg)
<!-- .element: class="grande" -->

Note:
El número es del Wilson Research Group 2024, no es una impresión: sólo el 14 %
de los proyectos sale bien en el primer silicio, o sea que seis de cada siete
necesitan al menos un respin. Y es el peor valor en veinte años de encuesta.
Preguntar quién hizo un tape-out y cómo salió engancha mejor que el gráfico.
Si preguntan de dónde salen los datos: `res/trends/data.json`, y las figuras se
regeneran con `make figs`.

---

## Tendencias

#### *Por qué: lo que hay adentro de un chip hoy*

![Crecimiento de la cantidad de bloques y de procesadores embebidos por chip](res/trends/complejidad.svg)
<!-- .element: class="grande" -->

---

## Tendencias

#### *Verificar no es una etapa, es la mitad del trabajo*

![Reparto del tiempo del verificador: casi la mitad se va en debug](res/trends/esfuerzo.svg)
<!-- .element: class="grande" -->

Note:
Acá está el argumento de por qué existe este curso: el esfuerzo de verificación
ya empató al de diseño. Verificar no es el paso final antes del tape-out: es la
mitad del proyecto, con su propio equipo y su propio lenguaje.

---

## Tendencias

#### *Y se verifica, sobre todo, con UVM*

![Adopcion de metodologias de verificacion: UVM contra las demas](res/trends/metodologia.svg)
<!-- .element: class="grande" -->

---

## ¿SystemVerilog es el *COBOL* de la electrónica?

| Lenguaje | Reserved Keywords |
| --- | --- |
| ANSI COBOL 85 | 357 |
| SystemVerilog | 248 |
| VHDL 2008 | 115 |
| Verilog 95 | 102 |
| C# | 102 |
| C++ | 82 |
| Python3.x | 33 |

> *"* No academic computer scientists participated in the design of COBOL;
>  all of those on the committee came from commerce or government"* ¿Parecido no?

Note:
Es un chiste con moraleja: SystemVerilog tiene 248 keywords —las del Annex B
del IEEE 1800-2017— y nadie las usa todas. En el curso vamos a usar unas
treinta. Con UVM pasa lo mismo: la librería es enorme y con seis o siete clases
se arma un testbench completo.
Sirve para bajarle la ansiedad al que llega asustado por el tamaño de UVM.
