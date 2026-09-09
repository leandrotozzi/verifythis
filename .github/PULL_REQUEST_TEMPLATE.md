<!-- Borrá lo que no aplique. Un PR de un typo no necesita más que la primera
     línea; el resto está para el que toca slides/ o code/. -->

## Qué cambia y por qué

<!-- Una o dos líneas. Qué cambió, no qué archivos tocaste. -->

## Checks

- [ ] `npm run check` en verde
- [ ] `npm run overflow` en verde (sólo si tocaste `slides/`)

## Si tocaste `slides/`

`index.html`, `libro/` y sus gemelos de `en/` **son generados y van commiteados
en el mismo PR** — es lo que hace que el curso ande con doble clic, sin build.
`npm run build` los regenera y `npm run check` falla si quedaron viejos.

- [ ] Corrí `npm run build` y los generados están en este PR
- [ ] Si el archivo ES ya estaba traducido: actualicé el EN, o lo dejo fallar y
      lo digo acá. Después de traducir, `node tools/lint-i18n.mjs --bless <archivo>`
- [ ] Si agregué o saqué material, los números de inventario quedaron al día
      (`npm run inventario` dice los reales; `npm run check` los verifica)

## Si tocaste `code/`

- [ ] `make <unidad>/<ejemplo>` pasa (o `make rapido` si es un ejemplo sin UVM)
- [ ] El comentario del ejemplo está en inglés — `code/` no se duplica, lo
      comparten las dos versiones del curso

---

Los detalles, en [CONTRIBUTING.md](../CONTRIBUTING.md). Al mandar el PR aceptás
que tu aporte se publique con la licencia que le corresponda a ese archivo
(ver [LICENSE](../LICENSE)).
