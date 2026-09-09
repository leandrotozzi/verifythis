## Autoevaluación

#### *Quince cosas que a esta altura tendrías que poder hacer · 1 de 3*

| ¿Puedo…? | Dónde está |
| --- | --- |
| **1 ·** Explicar por qué el **47 %** del tiempo de un verificador se va en debug, y qué hace este curso al respecto | [Tendencias](libro/dia1.html#tendencias) |
| **2 ·** Escribir un **plan de verificación** de cinco columnas para un DUT que no vi antes | [El plan de verificación](libro/dia1.html#el-plan-de-verificación) |
| **3 ·** Decir por qué **100 % de cobertura de código** no quiere decir que el DUT esté verificado | [Cobertura funcional](libro/dia1.html#cobertura-funcional) |
| **4 ·** Decir qué mirar **primero** cuando un `covergroup` reporta 0 % | [Cobertura funcional](libro/dia1.html#cobertura-funcional) |
| **5 ·** Explicar qué race evita un `clocking block` — y por qué igual son **opcionales** | [Interfaces y BFM](libro/dia1.html#interfaces-y-bfm) |

Note:
Esta rúbrica es para el alumno, no para el instructor, y conviene decirlo así:
nadie la corrige. Sirve para dos momentos distintos —antes del final, como guía
de estudio; y ahora mismo, como diagnóstico— y la instrucción es la misma en los
dos: leer la afirmación y contestarse *"¿se lo puedo explicar a alguien?"*, no
*"¿me suena?"*. La diferencia entre las dos respuestas es todo el curso.
Cada fila linkea a la sección del **libro**, que es la versión para leer de
corrido, con la nota del instructor adentro del texto. Un "no" no es una mala
noticia: es un link.
Si se dicta en clase, proyectar las tres slides y pedir manos por fila. Las tres
que más manos levanten son las que hay que repasar, y esa medición vale más que
el repaso completo.

---

## Autoevaluación

#### *Quince cosas que a esta altura tendrías que poder hacer · 2 de 3*

| ¿Puedo…? | Dónde está |
| --- | --- |
| **6 ·** Extender una clase y cambiarle el comportamiento **sin copiarla**, y decir qué hace `super` | [Clases y extensiones](libro/dia2.html#clases-y-extensiones) |
| **7 ·** Cambiar la clase que usa un testbench **sin tocar el `env`**, con un `set_type_override` | [El patrón factory](libro/dia2.html#el-patrón-factory) |
| **8 ·** Explicar por qué una simulación de UVM **termina en t=0** si nadie levanta un objection | [Tests](libro/dia3.html#tests) |
| **9 ·** Decir por qué `build_phase` corre de arriba hacia abajo y `connect_phase` al revés | [Components y fases](libro/dia3.html#components-y-fases) |
| **10 ·** Hacer que un scoreboard que falla diga **algo más** que "falló" | [Reporting](libro/dia3.html#reporting) |

Note:
La 8 y la 9 son las dos que más se contestan con un *"me suena"*: son mecánica de
la librería y se entienden mirando, hasta el día que hay que debuggear un
testbench que termina sin haber mandado un estímulo. Si el alumno duda en
cualquiera de las dos, la sección de Tests es media hora y las cierra.
La 10 es la que más rinde a largo plazo y la que más se subestima. Todo el curso
apunta al 47 % de la fila 1: un `uvm_error` que imprime *"FAIL"* deja al que
debuggea exactamente donde estaba, y uno que imprime la transaction, la
predicción y el tiempo le ahorra media mañana. Es la diferencia entre un
testbench que funciona y uno con el que se puede trabajar.

---

## Autoevaluación

#### *Quince cosas que a esta altura tendrías que poder hacer · 3 de 3*

| ¿Puedo…? | Dónde está |
| --- | --- |
| **11 ·** Colgar un subscriber nuevo de un analysis port **sin tocar al que publica** | [Un solo lugar que mira el cable](libro/dia4.html#un-solo-lugar-que-mira-el-cable) |
| **12 ·** Escribir una constraint que llegue a un caso de borde, y **medir** si el `dist` hace lo que dice | [Constrained random](libro/dia5.html#constrained-random) |
| **13 ·** Decir qué construye y qué **no** un agent con `is_active = UVM_PASSIVE` | [Agents](libro/dia6.html#agents) |
| **14 ·** Explicar por qué una `uvm_sequence` **no aparece** en `print_topology()` | [Sequences](libro/dia6.html#sequences) |
| **15 ·** Escribir una property que vea una violación de protocolo, y decir por qué `--assert` no es opcional | [Assertions (SVA)](libro/dia7.html#assertions-sva) |

- ¿Las quince? Entonces la que queda es el **capstone**: un esclavo APB, su
  spec, y el testbench entero desde una hoja en blanco

Note:
La 14 es la pregunta que se tira el día 3, cuando aparece el diagrama de clases
de UVM, y se contesta el día 6. Si el alumno la puede contestar, entendió la
división que explica media librería: `uvm_object` son los **datos** y
`uvm_component` es la **estructura**. Un objeto se crea y se tira; un componente
se construye una vez y dura toda la simulación.
La 12 dice *medir*, no *escribir*, y es a propósito: el ejercicio `d5b` existe
porque un `dist` con los pesos bien puestos puede dar un histograma que miente,
y el que no lo midió nunca no tiene forma de saberlo.
Y la última línea es la única honesta que se puede decir sobre las quince: son
condición necesaria, no suficiente. Lo que prueba que alguien sabe hacer esto es
un testbench propio andando, y ése es el capstone. Un alumno que marca las
quince y no lo termina no terminó el curso.
