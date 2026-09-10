# La marca

El logo del curso es el favicon: la **V de "Verify" dibujada con la asimetría de
un tilde de verificación** —brazo corto que baja, brazo largo que sube— y el `!`
del título al lado. Dos formas gruesas y tres colores, para que a 16 px no quede
nada que perder.

| | |
|:--|:--|
| Ámbar | `#e7ad52` |
| Fondo | `#111` |
| Blanco | `#f0f0f0` |

## Las tres piezas

| Archivo | Tamaño | Dónde va |
|:--|:--|:--|
| [`../css/favicon.svg`](../css/favicon.svg) | 32×32 | La pestaña del navegador. Es el original, dibujado a mano |
| [`social-card.png`](social-card.png) | 1280×640 | GitHub → Settings → General → **Social preview** |
| [`avatar.png`](avatar.png) | 500×500 | El avatar de una cuenta o de una organización |

Las dos PNG salen de `npm run social-card`, que rinde
[`../tools/social-card.html`](../tools/social-card.html) y
[`../tools/avatar.html`](../tools/avatar.html) con Chrome headless. **Ninguna de
las dos se puede subir por API**: GitHub no las expone. Se suben a mano, una vez.

El avatar lleva la marca al 68 % y centrada, en vez de tocar los bordes como el
favicon. No es capricho: GitHub recorta el avatar **en círculo** en la mitad de
los lugares donde lo muestra, y en el favicon el `!` llega hasta `x=28` de 32,
justo la esquina que el círculo se come.

## Un repositorio no tiene avatar

Vale la pena decirlo porque es la pregunta que aparece sola: el objeto `repo` de
la API **no tiene `avatar_url`**. Lo que se ve al lado del nombre del repo es
`owner.avatar_url`, o sea la foto de perfil del dueño. Hay tres caminos y cada
uno cuesta algo distinto:

1. **Cambiar el avatar personal.** El tilde aparece en este repo y también en
   todos los demás, en cada comentario y en el perfil. Reemplaza tu identidad en
   GitHub por la del curso.
2. **Crear una organización y mudar el repo.** Es lo que hacen los proyectos que
   muestran su propio logo. Pero la URL de Pages pasa de
   `leandrotozzi.github.io/verifythis` a `<org>.github.io/verifythis`, y esa URL
   está escrita **198 veces en 31 archivos** —el README, las slides, el libro, el
   `CITATION.cff`, y horneada adentro del PDF—. La etapa 10 pide justamente lo
   contrario: *congelar el layout de URLs* antes de grabar.
3. **Dejarlo como está.** La marca igual viaja: la tarjeta social es lo que se ve
   cuando alguien comparte el link, que es donde el logo hace el trabajo.

Mientras el curso se esté grabando, la 3 es la barata y la 2 es la que hay que
decidir **antes** de que exista el primer video, no después.
