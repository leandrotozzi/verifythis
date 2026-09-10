# Licencias

**Verify This! — Curso introductorio a UVM**
Copyright (c) 2016-2026 Leandro Tozzi

Este repositorio combina material propio con material de terceros, y por eso
tiene TRES licencias y una lista corta de exclusiones. Leer las cuatro
secciones.

> El `LICENSE` de la raiz es el texto de **CC BY 4.0** y nada mas. No es que el
> repo entero sea CC BY: es la licencia del activo principal —el curso— y la
> unica que GitHub sabe detectar en un archivo llamado `LICENSE`. El mapa
> completo es este archivo, y los textos de las tres estan en
> [`LICENSES/`](LICENSES/), con el nombre SPDX que pide REUSE.

Resumen:

    tools/ css/ js/ .github/     MIT
    code/                        Apache-2.0  (ver NOTICE y code/LICENSE)
    slides/ docs/ res/ web/ *.md CC BY 4.0
    vendor/ css/fonts/           de terceros, cada uno con la suya

Y lo generado hereda: index.html, en/, libro/, en/libro/ y res/print/ salen de
slides/, css/, js/ y res/ con `npm run build`, y valen lo que valen sus fuentes
-- CC BY 4.0 el texto y los diagramas, MIT el CSS y el JS, y la MIT de reveal.js
para el reveal.js que el deck lleva adentro.


## 1. HERRAMIENTAS  --  Licencia MIT

Aplica a: tools/ (incluido tools/template.html), css/, js/, .github/

No aplica a dos cosas que viven adentro de esos directorios y son de terceros:
css/fonts/ (las tipografias, SIL OFL 1.1 -- ver css/fonts/LICENSE) y js/forkit.js
(MIT de Hakim El Hattab). Ver la seccion 4.

Texto completo: [`LICENSES/MIT.txt`](LICENSES/MIT.txt).


## 2. EJEMPLOS DEL CURSO  --  Apache License 2.0

Aplica a: code/  (el DUT, los ejemplos por unidad y los ejercicios con su
solucion). Texto completo: [`LICENSES/Apache-2.0.txt`](LICENSES/Apache-2.0.txt),
tambien copiado en [`code/LICENSE`](code/LICENSE).

Se usa Apache-2.0 y no MIT por una razon concreta: parte de code/ es trabajo
derivado de los ejemplos de "The UVM Primer" de Ray Salemi, que su autor
publico bajo Apache-2.0. La Apache-2.0 permite el trabajo derivado; lo que pide
a cambio es que se acredite el origen y se digan los cambios. Eso esta en el
archivo NOTICE, y quien redistribuya code/ tiene que conservarlo.

En castellano y en dos lineas: podes usar, copiar, modificar, dictar y
redistribuir code/ —tambien comercialmente— conservando el NOTICE y el aviso de
copyright. No hace falta que consultes a nadie.


## 3. CONTENIDO DEL CURSO  --  CC BY 4.0

Aplica a: slides/, docs/, res/ (los diagramas), web/ (las landings),
README.md, code/README.md y demas texto del curso.

Creative Commons Attribution 4.0 International (CC BY 4.0) —
<https://creativecommons.org/licenses/by/4.0/>. Texto completo:
[`LICENSES/CC-BY-4.0.txt`](LICENSES/CC-BY-4.0.txt), que es el mismo que el
`LICENSE` de la raiz.

Sos libre de compartir y adaptar este material, incluso comercialmente, siempre
que des credito apropiado, enlaces a la licencia e indiques si hiciste cambios.

Atribucion sugerida:

    "Verify This! — Curso introductorio a UVM", por Leandro Tozzi
    https://github.com/leandrotozzi/verifythis — CC BY 4.0

Los graficos de tendencias de res/trends/ son obra original de este proyecto:
se generan de cero a partir de los porcentajes publicados del estudio de Wilson
Research Group / Siemens EDA. Los datos no son apropiables; la expresion
grafica del estudio si, y por eso no se usa.

Lo mismo vale para los diagramas de res/diagrams/ cuyo nombre termina en
_figNNN: el numero dice que figura del "UVM Primer" explica lo mismo, no que
sean esa figura. Estan dibujados de cero en SVG a mano, con el DUT VTALU de
este curso y no con el del libro. Ninguna imagen del libro, del LRM IEEE
1800.2 ni de la documentacion de Accellera se copia ni se redistribuye aca.


## 4. MATERIAL DE TERCEROS  --  NO cubierto por las licencias de arriba

Lo siguiente pertenece a sus autores originales y conserva su licencia, y el
texto de esa licencia viaja al lado de los archivos:

  vendor/reveal/    reveal.js 5.2.x — MIT, (c) 2011-2024 Hakim El Hattab y los
                    contribuyentes de reveal.js. Texto: vendor/reveal/LICENSE
  css/fonts/        Chakra Petch (c) 2018 The Chakra Petch Project Authors;
                    IBM Plex Sans e IBM Plex Mono (c) 2017 IBM Corp.
                    SIL OFL 1.1. Texto: css/fonts/LICENSE
  js/forkit.js      forkit.js 0.2 — MIT, (c) Hakim El Hattab. El aviso va en la
                    cabecera del propio archivo

Las tres se redistribuyen: vendor/ y css/ se copian tal cual al sitio de
GitHub Pages, y el reveal.js queda ademas embebido adentro de index.html.

Y una que NO se distribuye: code/.uvm/ es la UVM 2020.3.1 de Accellera
(Apache-2.0, https://github.com/accellera-official/uvm-core), que baja
`make uvm` en tu maquina y esta en .gitignore. El curso la usa y la ensena;
no la incluye. UVM y Accellera son marcas de Accellera Systems Initiative, y
este proyecto no esta afiliado ni respaldado por Accellera.
