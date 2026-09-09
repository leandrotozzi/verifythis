## El log dice que falló

#### *Y el DUT está sano*

```text
$ cd code/ejercicios/d1b && bash run.sh
FAILED: A: e5  B: 0  op: mul_op result: fe01 ovf: 0
```

- `e5 × 00` es `0`, no `fe01`. El scoreboard tiene razón: **algo falló**
- El DUT también tiene razón: **no está roto**. Ese `fe01` es el resultado de
  otra operación, que llegó tarde
- Y el log no tiene una línea más. Qué operación, en qué ciclo, quién pisó a
  quién: nada de eso está acá
- Ese hueco entre *"falló"* y *"por qué"* es **casi la mitad** del tiempo de un
  verificador, y es de lo que trata la semana

Note:
Ésta es la primera slide con algo corriendo, y va acá a propósito: antes de
cualquier gráfico, antes de la palabra UVM, el alumno tiene que haber visto el
problema. Es el ejercicio `d1b`, el segundo de hoy, y en clase conviene correrlo
en vivo — son cuatro segundos, no compila UVM.
La pregunta para tirar y **no** contestar: *"con esa línea, ¿por dónde
empezarías?"*. Las respuestas que van a salir son `$display` y volver a correr,
que es exactamente lo que el curso viene a reemplazar. La respuesta está en un
`ondas.vcd` que la corrida dejó al lado y que nadie abrió todavía.
Y el cierre honesto, que es la promesa del curso entero: no se trata de escribir
testbenches más rápido, se trata de que cuando falle —y va a fallar— el log diga
por qué. La cifra del bullet de abajo, el 47 %, sale de la encuesta que viene en
la slide que sigue.
