<!-- .slide: id="referencias" -->

## Referencias

- **IEEE 1800-2017** — SystemVerilog Language Reference Manual. El árbitro final
  de toda discusión de sintaxis.
- **IEEE 1800.2** / **Accellera UVM** — la metodología, y el *UVM User Guide*.
  El código de `uvm-core` lo tenés en disco: `make uvm`.
- **Verification Academy** — Siemens EDA ·
  [verificationacademy.com](https://verificationacademy.com)
- **Salemi, Ray.** *The UVM Primer* — Boston Light Press, 2013. El libro con el
  que aprendí UVM, y del que salieron varios de los ejemplos de `code/`.
- **2024 Siemens EDA / Wilson Research Group Functional Verification Study**.
  Fuente de los **datos** de la spec. Los gráficos son propios: se generan
  con `make figs` desde `res/trends/data.json`.
- **Sobre RAL**: el capítulo *Register Layer* del **UVM 1.2 User Guide** de
  Accellera es la referencia normativa, y la tabla de los veinticinco accesos de
  campo —`RW`, `WOC`, `W1C`…— está en el **IEEE 1800.2**, en `uvm_reg_field`. Lo
  que la unidad no usa vive en el mismo lugar: `add_hdl_path` para el backdoor,
  y **IP-XACT** (IEEE 1685) o **SystemRDL** (Accellera) para generar el modelo en
  vez de escribirlo.
- **Sobre los clocking blocks**, que es la discusión más viva del curso: los
  hilos de **Dave Rich** en Verification Academy (2014, 2022 y 2024), su paper
  *The Missing Link: The Testbench to DUT Connection*, y el **DV Coding Style
  Guide de lowRISC/OpenTitan**, que los hace obligatorios. El resumen, con los
  links y las citas, en **`docs/clocking-blocks.md`**.

Note:
La lista está ordenada por cuándo la vas a necesitar, y conviene decirlo así.
El LRM y el *User Guide* son de consulta: nadie los lee de corrido, se van a
buscar cuando hay una discusión de sintaxis o de semántica. La Verification
Academy es el lugar donde está casi todo lo que este curso dejó afuera, y es
gratis con registro.
Del libro de Salemi vale repetir lo que dice `docs/en-que-se-diferencia.md`: este
curso no lo reemplaza y no lo sigue. Si alguien quiere una segunda vuelta sobre
los mismos conceptos escrita por otra persona, es la mejor que hay para empezar.
Y el dato de los gráficos, porque es la parte que un alumno puede querer
verificar: los porcentajes de la unidad 1 son del estudio de Wilson Research
Group; los gráficos son propios y se regeneran con `make figs` desde un JSON que
está en el repo. Nada de la unidad 1 es una imagen bajada de internet.

---

<!-- .slide: id="el-libro" -->

## Si querés seguir leyendo

<div class="creditos creditos-ref">
<a class="libro" href="https://www.amazon.com/UVM-Primer-Step-Step-Introduction/dp/0974164933" target="_blank" rel="noopener">
<span class="libro-tapa" aria-hidden="true"></span>
<span class="libro-txt">
<span class="libro-kicker">El libro con el que aprendí</span>
<span class="libro-titulo">The UVM Primer</span>
<span class="libro-pie">Ray Salemi &middot; Boston Light Press, 2013 &middot; ISBN 978-0974164939</span>
</span>
</a>
<p class="libro-nota">Este curso no es ese libro: tiene otra estructura, otro DUT, otro simulador y cuatro unidades de material que el libro no cubre. Lo que sí comparte está acreditado en <code>NOTICE</code>, y la lista completa de diferencias está en <code>docs/en-que-se-diferencia.md</code>.</p>
</div>

Note:

Vale decirlo en voz alta cuando se llega acá: el libro es corto, está bien
escrito y sigue siendo la mejor forma de empezar en inglés. Si a alguien le
sirvió el curso, que lo compre.

---

## Créditos

- Parte de los ejemplos de `code/` deriva de los del **UVM Primer**, publicados
  por su autor bajo **Apache-2.0**. Acá siguen bajo Apache-2.0, con el `NOTICE`
  que la licencia pide y la lista de cambios.
- El curso —`slides/` y `docs/`— es **CC BY 4.0**. Las herramientas de `tools/`,
  **MIT**.
- Los gráficos de tendencias son propios, hechos a partir de los porcentajes
  publicados del estudio de Wilson Research Group / Siemens EDA.
- **reveal.js** y **forkit.js** de Hakim El Hattab (MIT); las tipografías
  Chakra Petch e IBM Plex bajo SIL OFL 1.1.

Note:
Esta slide no es formalismo legal, y conviene decir por qué está: el curso pide
que se lo cite, así que tiene que citar él primero. Lo que se usó prestado está
nombrado, con su licencia y con la lista de cambios en el `NOTICE`.
Lo práctico para el que quiera reusar el material: **CC BY 4.0** las slides y los
docs, **Apache-2.0** el código, **MIT** las herramientas. Se puede dictar,
adaptar, traducir y cobrar. La única condición es citar la fuente, y no hay
cláusula de "no comercial" escondida.
Si alguien pregunta por qué tres licencias en vez de una: porque son tres cosas
distintas. El código deriva de código Apache-2.0 y tiene que seguir siéndolo; las
slides son obra propia y CC BY es la que entiende un ámbito académico; las
herramientas son software y MIT es lo que espera cualquiera que las copie.
