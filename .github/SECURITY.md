# Seguridad

Esto es material didáctico: slides, un libro HTML y ejemplos de SystemVerilog.
No hay servidor, no hay base de datos, no hay cuentas de usuario y nada acá se
despliega en producción de nadie. **No esperes un CVE.**

Dicho eso, el repo hace tres cosas que sí tienen superficie, y de esas sí quiero
saber:

1. **Bajar cosas de internet.** `tools/get-uvm.sh` y el `Dockerfile` traen la UVM
   de Accellera y el fuente de Verilator desde GitHub, por HTTPS y por tag fijo,
   **sin verificar checksum**. Si conseguís que eso baje otra cosa, es un
   problema y quiero saberlo.
2. **Correr scripts.** Cada ejemplo es un `run.sh` que compila y ejecuta un
   binario nativo con Verilator. Corren con tus permisos, en tu máquina. Si
   alguno escribe fuera de su `obj_dir/`, es un bug.
3. **Publicar HTML.** El deck y el libro salen de `slides/*.md` por
   `tools/build.mjs` y se sirven en GitHub Pages. Un XSS almacenado vía una
   slide es improbable —el contenido lo escribe el mantenedor— pero contaría.

Fuera de eso: **si el ejemplo del curso enseña una práctica de verificación
insegura o incorrecta, eso no es un issue de seguridad, es un issue de
contenido** y va por [el formulario de typo](ISSUE_TEMPLATE/typo.yml).

## Cómo reportar

Mail a **leandro.tozzi@gmail.com**, o [aviso privado por
GitHub](https://github.com/leandrotozzi/verifythis/security/advisories/new) si
está habilitado. Contesto en unos días; esto lo mantiene una persona en su
tiempo libre y no hay SLA.

No hace falta que esperes para hablar del tema: si ya es público (una versión
vieja de una dependencia, un tag movido aguas arriba), abrí un issue normal y
listo.

## Qué versión se arregla

La que está en `master`. No hay ramas de soporte ni backports: el curso se
mantiene hacia adelante.
