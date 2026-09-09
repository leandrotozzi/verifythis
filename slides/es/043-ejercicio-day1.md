## Ejercicio · Día 1 · 1 de 2

#### *Una operación nueva, de punta a punta*

`cd code/ejercicios/d1 && bash run.sh`
<!-- .element: class="comando" -->

- La VTALU tiene un **opcode libre**, `3'b110`. Enseñale a desplazar, y
  enseñale también al TB que lo tiene que verificar
- Se toca en **tres** lugares: el RTL, el estímulo con su chequeo, y **la
  medida** — el bin que hoy no existe
- El `run.sh` falla hasta que imprime `EXERCISE OK`; la solución está al lado

Note:
Media hora, y conviene dejarlos solos: el enunciado y el README alcanzan.
El tropiezo garantizado es el ancho: el hardware desplaza por `B[2:0]`, no por
`B` entero, así que con `B = 8'h20` corre cero lugares y no treinta y dos. El
modelo del scoreboard tiene que hacer lo mismo o el TB que ellos mismos
escribieron los va a acusar. Está avisado en el README, y aun así pasa.
El tercer paso es el que más se saltea y el único que falla **en silencio**:
`bins single_cycle[]` cubre el rango `[add_op : xor_op]`, que llega hasta
`3'b100`. `shr_op` queda afuera de todos los bins, la simulación pasa en verde y
la cobertura no se mueve. Ahí está la lección que vale para el resto del curso:
un opcode que nadie mide es un opcode que nadie verificó.
Con la solución la cobertura pasa de 86,8 % a 100 %. Vale mostrar el número
antes y después: es el argumento entero de la mañana en dos líneas del reporte.
