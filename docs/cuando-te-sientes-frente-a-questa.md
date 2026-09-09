# Cuando te sientes frente a Questa

Una página, para el lunes. Este curso corre entero con **Verilator**, que es una
decisión de identidad y no una limitación disimulada: todo lo que ves acá lo
podés repetir sin pedirle una licencia a nadie. Pero tu primer trabajo va a usar
**Questa, VCS o Xcelium**, y lo que cambia se cuenta en una carilla.

Esto **no** es un flujo alternativo. No hay `run.do` en el repo, no los va a
haber, y no hace falta: lo que sigue es la traducción de lo que ya sabés.

## Lo que no cambia (que es casi todo)

**El testbench entero.** Las clases, las fases, el `config_db`, la factory, los
analysis ports, las sequences, el RAL, las properties: es la misma librería, la
misma versión del estándar, el mismo código. Un testbench del curso compila en
Questa sin tocar una línea de SystemVerilog.

**Los plusargs.** `+UVM_TESTNAME`, `+UVM_VERBOSITY`, `+UVM_TIMEOUT`,
`+UVM_OBJECTION_TRACE`, `+UVM_PHASE_TRACE`, `+UVM_CONFIG_DB_TRACE`,
`+uvm_set_verbosity` — son de UVM, no del simulador. La tabla del apéndice de
debug vale igual.

**El Report Summary.** Los `UVM_ERROR : 0` que leés al final son los mismos, y
siguen sin cambiar el código de salida: si armás un script, se sigue parseando el
log.

## Lo que cambia: los comandos

| Acá | En Questa |
|---|---|
| `verilator --binary --timing -f tb.f` | `vlog -sv +incdir+... tb.sv` (compila a una librería, `work/`) |
| — | `vopt top -o top_opt +acc` — el paso de optimización; `+acc` deja los objetos visibles para el debug |
| `./obj_dir/top/sim +UVM_TESTNAME=...` | `vsim -c top_opt +UVM_TESTNAME=... -do "run -all; quit"` |
| `--coverage-user` | `vlog -cover` / `vsim -coverage`, y `coverage save` al final |
| `verilator_coverage --write a.dat b.dat` | `vcover merge merged.ucdb a.ucdb b.ucdb` |
| `verilator_coverage reporte.dat` | `vcover report -details merged.ucdb`, o el GUI |
| `--assert` | nada: las assertions concurrentes están **prendidas por defecto** |
| `--trace` + `gtkwave ondas.vcd` | `vsim -voptargs=+acc` + `add wave -r /*`, y el visor es el mismo programa |
| `+verilator+seed+7` | `vsim -sv_seed 7` (o `-sv_seed random`) |
| `-Wno-fatal` | `vlog -suppress <número>` |

La diferencia estructural es que Questa tiene **tres pasos** —`vlog`, `vopt`,
`vsim`— donde Verilator tiene uno. El del medio es el que sorprende: si
optimizás sin `+acc`, el testbench corre pero el visor de ondas no encuentra
nada, y parece un problema del testbench.

Y UVM ya viene con el simulador: `vlog -L mtiUvm` o
`+incdir+$QUESTA_HOME/verilog_src/uvm-1.2/src`, según la versión. No hace falta
bajar `uvm-core` como hace `make uvm`.

## Lo que empieza a andar

Cuatro cosas que el curso te enseñó y **no** te pudo mostrar corriendo. Están
documentadas una por una en [`verilator.md`](verilator.md); en Questa
simplemente funcionan:

- **Los bins de transición.** `bins opn_rst[] = (op => rst_op)`, `[* 2]`,
  `[-> 2]`, `[= 2]`. En el curso están entre `` `ifndef VERILATOR `` — las filas
  4, 5 y 6 del plan de verificación. Sacales el `ifndef` y se miden.
- **`binsof` / `intersect`.** Los bins explícitos de un cross. Verilator los
  ignora con un `%Warning-COVERIGN`; acá cuentan, y el número de cobertura del
  curso sube unos puntos de golpe.
- **`option.at_least` en el covergroup**, `option.weight`,
  `type_option.merge_instances` y la cobertura *type-wide* con
  `get_coverage()`. Verilator ignora las cuatro, y `at_least` sin avisar.
- **`solve … before`** y `randomize() with {}` sobre un campo con `dist`. Los dos
  rodeos que el curso enseña —pedir el reparto con un `dist`, y apagar la
  constraint con `constraint_mode(0)`— siguen siendo buen estilo, pero dejan de
  ser obligatorios.

Y dos que son de otra categoría:

- **El visor de transacciones.** `uvm_transaction` con `begin_tr`/`end_tr`, y
  `do_record` con las field macros, dibujan cada transaction como una barra en la
  ventana de ondas, con sus campos adentro. Es la razón por la que existen
  `do_record` y las field macros, y es lo que hace que valga la pena aprender a
  leerlas aunque el curso escriba `convert2string` a mano.
- **`bind`.** Verilator lo soporta, pero el curso pone las properties adentro de
  la interface. En un proyecto real el RTL no se toca: las assertions se
  *bindean* desde afuera, `bind mi_dut mis_props p_inst (.*)`, y viven en un
  archivo aparte que el diseñador nunca abre.

## Lo que se pone más difícil

- **Los tiempos.** Un `vsim` de un SoC tarda horas y se corre en una granja, no
  en tu laptop. `make regresion` con cinco semillas pasa a ser un job de LSF o
  Slurm con doscientas.
- **Las licencias.** Son un recurso compartido y contado: una regresión de
  doscientas semillas puede quedar encolada porque alguien más está corriendo.
  Es la restricción que más va a moldear cómo trabajás, y la única contra la que
  este curso no te preparó.
- **El GUI.** Questa se usa mucho con interfaz gráfica, y la tentación es
  debuggear a mano en vez de dejar el testbench diciendo lo que pasó. El 47 % del
  día 1 no cambia: un `uvm_error` que dice A, B, la operación y las dos
  predicciones te ahorra la misma media mañana con licencia que sin ella.

## Lo primero que conviene hacer

1. Compilá **un ejemplo del curso** en el simulador del trabajo. `u4/tests` es el
   más chico que usa UVM entera. Si compila —y compila—, ya sabés que lo que
   aprendiste es portable.
2. Sacale el `` `ifndef VERILATOR `` a los covergroups y mirá subir la cobertura.
   Es la mejor forma de entender qué te estaba faltando.
3. Pedile a alguien el `Makefile` o el `run.do` del proyecto y leelo entero una
   vez. Las tres cuartas partes son rutas y flags de la casa; el cuarto que
   queda es esta tabla.
