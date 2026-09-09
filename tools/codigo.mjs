// La directiva {{code:}}: una sola implementacion para el deck y para el libro.
//
//   {{code:ruta}}                el archivo entero
//   {{code:ruta#nombre}}         el bloque que se llama asi
//   {{code:ruta#clase.metodo}}   cuando el nombre esta dos veces en el archivo
//   {{code:ruta|lines=12-24}}    por numero -- ultimo recurso, ver abajo
//
// El recorte por numero de linea se pudre en silencio: cuando el ejemplo crece
// arriba del bloque, el rango no se mueve y la slide muestra otro codigo. Nadie
// se entera hasta que alguien mira la slide en camara. Por eso la forma normal
// es por NOMBRE, y el nombre sale de dos lados:
//
//   1. del propio SystemVerilog -- `function void write`, `class scoreboard`,
//      `always ... begin : cmd_monitor`. No hay nada que agregar al fuente: el
//      bloque ya esta delimitado y ya tiene nombre. Los comentarios pegados
//      arriba de la declaracion entran, que es donde vive la explicacion.
//   2. de un marcador, para el trozo que el lenguaje no nombra (medio initial,
//      un fork/join, tres lineas sueltas):
//
//        // cb: envio
//        ...
//        // cb: end
//
// Los marcadores se borran de TODO bloque emitido, asi que anidan sin drama y
// la slide nunca muestra metadata del build. Si el nombre no esta, esta dos
// veces o no cierra, se tira -- el build muere y dice cual slide. Nunca miente.
import { readFile } from 'node:fs/promises';
import path from 'node:path';

export const RE_CODE = /^([ \t]*)\{\{code:([^}|#]+?)(?:#([\w.-]+))?(?:\|lines=(\d+)-(\d+))?\}\}[ \t]*$/gm;

// extension -> lenguaje de highlight.js.
export const LANG = {
  '.sv': 'sv', '.svh': 'sv', '.vhd': 'vhdl', '.vhdl': 'vhdl',
  '.do': 'tcl', '.py': 'python',
  '.f': 'plaintext', '.txt': 'plaintext', '.questa': 'plaintext', '.log': 'plaintext',
};

// El comentario de linea depende del lenguaje: en SystemVerilog `#` es un delay.
const COMENTARIO = { '.py': '#', '.sh': '#', '.vhd': '--', '.vhdl': '--' };

// keyword de apertura -> keyword de cierre. `constraint` cierra con llave.
const CIERRE = {
  module: 'endmodule', interface: 'endinterface', package: 'endpackage',
  program: 'endprogram', class: 'endclass', function: 'endfunction',
  task: 'endtask', covergroup: 'endgroup', property: 'endproperty',
  sequence: 'endsequence', checker: 'endchecker', constraint: null,
};
const KW = Object.keys(CIERRE).join('|');
const RE_DECL = new RegExp(`^\\s*(?:(?:virtual|static|protected|local|automatic|pure|rand|extern)\\s+)*(${KW})\\b(.*)$`);

// El nombre que declara una linea, o null. Para function/task es el identificador
// que va antes del parentesis; para el resto, el primero despues del keyword.
export function declara(linea) {
  const lab = linea.match(/\bbegin\s*:\s*(\w+)/);
  if (lab) return { kw: 'begin', nombre: lab[1] };
  const m = RE_DECL.exec(linea);
  if (!m) return null;
  const [, kw, resto] = m;
  const n = (kw === 'function' || kw === 'task')
    ? (resto.match(/(\w+)\s*\(/) ?? resto.match(/(\w+)\s*;/))
    : resto.match(/([A-Za-z_]\w*)/);
  return n ? { kw, nombre: n[1] } : null;
}

// Donde cierra el bloque que abre en `desde`. Cuenta el par de keywords propio
// del bloque e ignora begin/end, case/endcase y fork/join, que no lo cierran.
// Corre sobre el codigo SIN comentarios ni strings: un "// copy all parent class
// data" abria una class fantasma que no cerraba nunca.
function cierraEn(lines, desde, kw, nombre) {
  if (kw === 'begin') {
    const re = new RegExp(`^\\s*end\\s*:\\s*${nombre}\\b`);
    return lines.findIndex((l, n) => n > desde && re.test(l));
  }
  if (kw === 'constraint') {
    let llaves = 0;
    for (let n = desde; n < lines.length; n++) {
      llaves += (lines[n].match(/\{/g) ?? []).length - (lines[n].match(/\}/g) ?? []).length;
      if (llaves === 0 && /\{/.test(lines.slice(desde, n + 1).join('\n'))) return n;
    }
    return -1;
  }
  const abre = new RegExp(`\\b${kw}\\b`, 'g');
  const cierra = new RegExp(`\\b${CIERRE[kw]}\\b`, 'g');
  let hondo = 1;
  for (let n = desde + 1; n < lines.length; n++) {
    hondo += (lines[n].match(abre) ?? []).length - (lines[n].match(cierra) ?? []).length;
    if (hondo <= 0) return n;
  }
  return -1;
}

// Resuelve un #nombre a un rango [ini, fin] de indices, inclusive. El punto se
// resuelve de a un tramo: #clase.metodo busca el metodo adentro de la clase.
function resolver(lines, codigo, ruta, nombre, marca, com, off = 0) {
  const [cabeza, ...cola] = nombre.split('.');
  const abre = lines.findIndex(l => marca.exec(l)?.[1] === cabeza);
  let ini, fin;
  if (abre >= 0) {
    const cierra = lines.findIndex((l, n) => n > abre && marca.exec(l)?.[1] === 'end');
    if (cierra < 0) throw new Error(`el marcador "cb: ${cabeza}" de ${ruta} no tiene su "cb: end"`);
    [ini, fin] = [abre + 1, cierra - 1];
  } else {
    const hits = codigo.map((l, n) => declara(l)?.nombre === cabeza ? n : -1).filter(n => n >= 0);
    if (!hits.length) throw new Error(`${ruta} no tiene ningun bloque ni marcador "${cabeza}"`);
    if (hits.length > 1) throw new Error(`"${cabeza}" esta ${hits.length} veces en ${ruta} (lineas ${hits.map(n => n + 1 + off).join(', ')}) -- desambigua con #padre.${cabeza}`);
    const { kw } = declara(codigo[hits[0]]);
    fin = cierraEn(codigo, hits[0], kw, cabeza);
    if (fin < 0) throw new Error(`no encontre donde cierra "${cabeza}" en ${ruta}`);
    // Los comentarios pegados arriba de la declaracion son parte del bloque:
    // explican lo que la slide va a mostrar.
    ini = hits[0];
    while (ini > 0 && com.test(lines[ini - 1]) && !marca.test(lines[ini - 1])) ini--;
  }
  if (!cola.length) return [ini + off, fin + off];
  return resolver(lines.slice(ini, fin + 1), codigo.slice(ini, fin + 1), ruta, cola.join('.'), marca, com, off + ini);
}

// Lee el archivo y devuelve el recorte que pide la directiva. `recorte` y
// `lineas` ya vienen sin los marcadores; `donde` es como citarlo al pie.
export async function recortar(rel, simbolo, from, to) {
  const texto = await readFile(rel, 'utf8');
  const ext = path.extname(rel).toLowerCase();
  const esc = (COMENTARIO[ext] ?? '//').replace(/[-/]/g, '\\$&');
  const marca = new RegExp(`^\\s*${esc}\\s*cb:\\s*(\\S+)\\s*$`);
  const com = new RegExp(`^\\s*${esc}`);
  const lines = texto.replace(/\s+$/, '').split('\n');
  // Los keywords se buscan en el codigo pelado: sin comentario de linea y sin
  // strings, que es donde aparecen los `class`, `module` y `end*` de mentira.
  const pelar = new RegExp(`${esc}.*$`);
  const codigo = lines.map(l => l.replace(pelar, '').replace(/"[^"]*"/g, '""'));

  let recorte = lines, donde = '';
  if (simbolo) {
    const [ini, fin] = resolver(lines, codigo, rel, simbolo, marca, com);
    recorte = lines.slice(ini, fin + 1);
    donde = ` · #${simbolo}`;
  } else if (from) {
    if (+to > lines.length) throw new Error(`{{code:${rel}|lines=${from}-${to}}} -> solo tiene ${lines.length} lineas`);
    recorte = lines.slice(+from - 1, +to);
    donde = ` · líneas ${from}-${to} de ${lines.length}`;
  }
  const limpiar = ls => ls.filter(l => !marca.test(l));
  return {
    lineas: limpiar(lines),
    recorte: limpiar(recorte),
    recortado: Boolean(simbolo || from),
    donde,
    lang: LANG[ext] ?? 'plaintext',
  };
}
