[English](README.md) · **Castellano**

# Día 1 — una operación nueva, de punta a punta

Dos archivos: una copia del bloque de un ciclo del DUT y una copia del testbench
convencional, puestas acá para que las rompas tranquilo. El top del VTALU y el
multiplicador salen del curso, sin tocar.

La VTALU tiene **un opcode libre**: `3'b110`. Está reservado a propósito, y hoy
no hace nada. Vas a enseñarle a desplazar, y a enseñarle también al testbench
que lo tiene que verificar.

## Qué se pide

1. **`vtalu_1c.sv`** — implementá el shift a la derecha en `3'b110`.
   Ojo con el ancho: el hardware desplaza por `B[2:0]`, no por `B` entero. Con
   `B = 8'h20` corre **cero** lugares, no treinta y dos.
2. **`vtalu_tb.sv`** — agregá `shr_op = 3'b110` al `operation_t`, hacé que
   `get_op()` la genere y que el scoreboard la prediga **igual que el hardware**.
3. **`vtalu_tb.sv`, el covergroup** — `bins single_cycle[]` cubre el rango
   `[add_op : xor_op]`, que llega hasta `3'b100`. `shr_op` queda **afuera de
   todos los bins**: se ejecuta, pasa el scoreboard, y no aparece en el reporte.
   Metelo.

Listo cuando `bash run.sh` termina con `EXERCISE OK`. El corrector mira tres
cosas y ninguna sale de los archivos que editás: `chequeo.sv` —que está
*bindeado* al top y no se toca— cuenta los shifts sobre los pines del DUT y
predice el resultado por su cuenta; el scoreboard tuyo tiene que haber mirado
**todas** las operaciones que el bus contestó; y la base de datos de cobertura
tiene que cerrar **sin un solo bin en cero** y con `single_cycle` en **siete**
bins. Ese último es el paso 3: un total de bins más grande no prueba nada,
porque cualquier `coverpoint` de más lo sube sin medir el opcode nuevo.

## Cómo se corre

```sh
bash run.sh              # con tus archivos
SOLUCION=1 bash run.sh   # con los de solucion/, para comparar
```

Si un resultado no coincide con el modelo, el `$error` del scoreboard aborta la
simulación: Verilator lo trata como una aserción.

## Cuánto tarda

No usa UVM: compila y corre en **segundos**, sin `ccache` y sin `z3`.

## Lo que practica

La spec del VTALU, el testbench convencional y la cobertura funcional. Y dos
lecciones que no están en ninguna slide:

- **Una operación nueva se toca en tres lugares** —el DUT, el estímulo con su
  chequeo, y la medida— y si te olvidás de uno, el que se entera es el TB.
- **Un opcode que nadie mide es un opcode que nadie verificó.** El paso 3 es el
  que más se saltea, y es el único de los tres que la simulación deja pasar **en
  silencio**: sin tocar los bins pasa en verde, y el porcentaje de cobertura
  igual te dice 100 %. Por eso el corrector cuenta bins y no mira el porcentaje.

Con la solución, la cobertura pasa de **86,8 % (66 bins de 76) a 100 %
(77 de 77)**: el shift agrega su propio bin y de paso cierra los que quedaban
abiertos. Los diez que faltaban eran **uno solo**: Verilator reparte los bins
automáticos de `all_ops` por el tipo de base —`bit [2:0]`— y no por miembro del
enum, así que inventa un casillero para `3'b110`, el valor que el enum no
tenía, y lo cruza nueve veces con `a_leg` y `b_leg`. El shift es justamente
`3'b110`, y por eso lo llena de paso; en Questa se arranca de 100 %. Mirá el
denominador, no el porcentaje: un covergroup que nunca declaró el bin tampoco
lo cuenta como faltante, así que sin el paso 3 el reporte también dice 100 %,
pero de 76.
