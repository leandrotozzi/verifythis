## Tendencias

#### *El primer silicio casi nunca sale bien*

![Cómo terminan los proyectos IC/ASIC en 2024: 14 % acierta el primer silicio y 75 % llega atrasado](res/trends/resultado.svg)
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

![Qué tienen adentro los IC/ASIC de 2024: relojes asincrónicos, procesador embebido, seguridad, IA, RISC-V y safety](res/trends/complejidad.svg)
<!-- .element: class="grande" -->

---

## Tendencias

#### *Verificar no es una etapa, es la mitad del trabajo*

![Del tiempo del diseñador, 49 % va a verificación; del tiempo del verificador, 47 % va a debug](res/trends/esfuerzo.svg)
<!-- .element: class="grande" -->

Note:
Acá está el argumento de por qué existe este curso: el esfuerzo de verificación
ya empató al de diseño. Verificar no es el paso final antes del tape-out: es la
mitad del proyecto, con su propio equipo y su propio lenguaje.

---

## Tendencias

#### *Y se verifica, sobre todo, con UVM*

![Con qué se verifica en 2024: UVM al 80 % en IC/ASIC y al 50 % en FPGA](res/trends/metodologia.svg)
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
