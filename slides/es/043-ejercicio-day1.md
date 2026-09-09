## Ejercicio · Día 1 · 1 de 2

#### *Una operación nueva, de punta a punta*

`cd code/ejercicios/d1 && bash run.sh`
<!-- .element: class="comando" -->

- La VTALU tiene un **opcode libre**, `3'b110`. Enseñale a desplazar, y
  enseñale también al TB que lo tiene que verificar
- Se toca en **tres** lugares: el RTL, el estímulo con su chequeo, y **la
  medida** — el bin que hoy no existe
- El `run.sh` falla hasta que imprime `EXERCISE OK` **y el reporte cierra con
  77 bins cubiertos**; la solución está al lado

Note:
Media hora, y conviene dejarlos solos: el enunciado y el README alcanzan.
El tropiezo garantizado es el ancho: el hardware desplaza por `B[2:0]`, no por
`B` entero, así que con `B = 8'h20` corre cero lugares y no treinta y dos. El
modelo del scoreboard tiene que hacer lo mismo o el TB que ellos mismos
escribieron los va a acusar. Está avisado en el README, y aun así pasa.
El tercer paso es el que más se saltea y el único que falla **en silencio**:
`bins single_cycle[]` cubre el rango `[add_op : xor_op]`, que llega hasta
`3'b100`. `shr_op` queda afuera de todos los bins, la simulación pasa en verde
y —acá está lo peor— el reporte sigue diciendo **100 %**: 76 de 76. El bin que
falta no baja el porcentaje porque nunca llegó a entrar en el denominador. Ahí
está la lección que vale para el resto del curso: un opcode que nadie mide es un
opcode que nadie verificó, y el porcentaje es justo la métrica que no lo ve.
Con la solución son 77 de 77, y se arranca en 86,8 % (66 de 76). Vale mostrar
los dos números, no sólo el porcentaje: por eso el `run.sh` exige la cantidad de
bins y no el 100 %, que un trabajo a medias también alcanza.
