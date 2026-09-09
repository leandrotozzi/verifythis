# Cómo colaborar

Gracias por venir hasta acá. Este curso es de una persona y se mejora con lo que
manda la gente que lo usa: un typo, un ejemplo que no corre en tu máquina, una
explicación que no se entiende.

Antes que nada, lo único que se pide de arriba:
[el código de conducta](.github/CODE_OF_CONDUCT.md). Son treinta líneas y se
resumen en una — que alguien no entienda es información sobre el material, no
sobre esa persona.

**No hace falta saber UVM para ayudar.** El aporte más valioso que existe es el
del que está haciendo el curso por primera vez y se traba: eso es un bug del
material, no tuyo.

## Lo más rápido: un issue

- **Un typo o un error de contenido** → [issue de typo](../../issues/new?template=typo.yml).
  Con la slide o el archivo alcanza.
- **Un ejemplo no corre** → [issue de ejemplo](../../issues/new?template=ejemplo.yml).
  Van tres cosas y las tres importan: **versión de Verilator**
  (`verilator --version`), **sistema operativo**, y la **salida del error**.
- **Una duda de un ejercicio** → [Discussions](../../discussions), no un issue.
  Hay una categoría por día.

## Un pull request

Todo el material vive en dos lugares: `slides/<idioma>/*.md` para el curso y
`code/` para los ejemplos. Nada más se edita a mano.

El curso está en **dos idiomas** y sólo tres cosas existen por duplicado: las
slides (`slides/es/` es el original, `slides/en/` la traducción), los `README`
de los ejercicios (`README.md` y `README.en.md` al lado) y el README de la raíz
—que va al revés, porque GitHub sólo renderiza `README.md`: ahí está el
**inglés**, y el original en castellano es `README.es.md`—. `code/`, `res/` y los
diagramas **no se duplican** —están en inglés y los comparten las dos
versiones—, y por eso una corrección a un ejemplo arregla el curso entero de una.

```sh
git clone https://github.com/leandrotozzi/verifythis
cd verifythis
npm install                       # sólo para poder regenerar el deck
```

### La regla que no se puede saltear

`index.html` y `libro/` están **commiteados a propósito**: es lo que hace que el
curso ande abriendo un archivo con doble clic, sin build y sin internet. Están
generados, así que **cualquier cambio en `slides/` los desactualiza**.

```sh
npm run build      # slides/ -> index.html + libro/ + dist/
npm run check      # falla si index.html o libro/ quedaron viejos
npm run overflow   # falla si alguna slide se recorta, en pantalla o impresa
```

Los tres en verde, y `index.html` + `libro/` —y sus gemelos de `en/`— en el
mismo commit que el cambio en `slides/`. El CI corre exactamente eso.

### Si tocaste una slide que ya está traducida

`npm run check` corre `tools/lint-i18n.mjs`, que compara los dos árboles y falla
si divergieron. Chequea dos cosas distintas:

- **La estructura**: misma cantidad de slides, los mismos `{{code:}}` en el mismo
  orden, los mismos `id="dayN"`, los mismos quizzes con la respuesta en el mismo
  lugar, y `Note:` en las mismas slides.
- **El sentido**: cada archivo de `slides/en/` lleva el sha del archivo en
  castellano del que salió. Si editás el castellano, el check falla diciendo qué
  traducción quedó vieja — que es la divergencia que ninguna regla estructural ve.

Después de actualizar la traducción, se re-sella:

```sh
node tools/lint-i18n.mjs --bless slides/en/060-factory.md
```

Si todavía no la vas a traducir, dejalo fallar y avisá en el PR: es mejor un
check en rojo que una versión que dice otra cosa.

### Si tocaste `code/`

```sh
make u4/tests      # el ejemplo que tocaste
make rapido        # todos los ejemplos sin UVM: segundos
make ejercicios    # las 15 soluciones (lento: nueve compilan UVM)
```

Hace falta **Verilator ≥ 5.050** y **z3**. Si no los tenés a mano, el botón de
Codespaces del README los trae adentro y no hay que instalar nada.

### Cómo escribir una slide

- Una slide por bloque, separadas por `---` en una línea sola.
- **Toda slide de concepto lleva `Note:`**, que es lo que un instructor diría en
  voz alta. Es la mitad del curso para el que estudia solo, y `npm run check` te
  dice cuántas slides quedaron sin nota.
- El código **no se pega**: se incluye desde `code/` con `{{code:ruta}}` o
  `{{code:ruta|lines=12-24}}`. Así el ejemplo de la slide es literalmente el que
  corre.
- El **título** va en `## Nombre de la sección` y el subtítulo en
  `#### *en itálica*`. Un `###` hace fallar el lint: se dibuja más grande y
  parte la voz del deck en dos.
- **No escribas a mano cuántas slides, ejemplos o preguntas hay.** Esos nueve
  números los cuenta `tools/inventario.mjs` desde el filesystem, y `npm run
  check` compara contra él **cada número escrito en el repo** —en dígitos y en
  letras—. Si agregás una slide y algún texto queda diciendo el número viejo, el
  check falla y te dice dónde. `npm run inventario` los imprime.
- Si la slide se pasa de alto, `npm run overflow` te lo dice antes que el
  proyector.

### Cómo escribir un commit

Mensajes en castellano, con el prefijo del área: `feat(curso)`, `fix(code)`,
`docs`. La primera línea dice **qué cambió**, no qué archivos se tocaron.

## Lo que no va

- **Traducciones a un idioma que no sea inglés.** El curso mantiene dos y no
  más: castellano —el original— e inglés. Un tercero nadie lo va a poder
  revisar, y una traducción que nadie revisa envejece peor que no tenerla.
- **Cambiar de simulador.** Verilator es el único, y es una decisión, no una
  limitación: es lo que hace que cualquiera pueda correr todo sin licencias.
- **Temas nuevos grandes** (RAL, un DUT nuevo, videos) sin abrir antes una
  discusión. El curso entra en siete días y ese límite lo defiende.

## Licencia

El repo tiene tres licencias: **MIT** para las herramientas, **Apache-2.0** para
los ejemplos de `code/` y **CC BY 4.0** para el contenido del curso. Está todo en
[`LICENSE`](LICENSE), y conviene leerlo antes de mandar un ejemplo nuevo.

Si mandás un ejemplo de `code/`, va bajo Apache-2.0 y el [`NOTICE`](NOTICE)
tiene que seguir intacto: parte de `code/` deriva de los ejemplos del *UVM
Primer*, que su autor publicó bajo esa misma licencia.

Al mandar un PR aceptás que tu aporte se publique con la licencia que le
corresponda a ese archivo.
