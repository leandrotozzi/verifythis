// hljs recortado: solo los lenguajes que emite build.mjs (su tabla LANG) mas
// bash, por los ```sh / ```bash de las slides. El paquete completo que bundlea
// reveal trae ~190 lenguajes y pesa 940 KB; con estos seis ronda los 35 KB.
// vendor.mjs lo inyecta en lugar de 'highlight.js' al bundlear el plugin.
import hljs from 'highlight.js/lib/core';
import bash from 'highlight.js/lib/languages/bash';
import plaintext from 'highlight.js/lib/languages/plaintext';
import python from 'highlight.js/lib/languages/python';
import tcl from 'highlight.js/lib/languages/tcl';
import vhdl from 'highlight.js/lib/languages/vhdl';
// El 'verilog' de hljs se reemplaza por la gramatica propia: emite tres clases
// de token y deja sin pintar las macros `uvm_* y las clases uvm_*, que es todo
// lo que el curso ensena. Se registra bajo 'systemverilog' con los alias
// sv/svh/v/verilog, asi que nadie se queda sin lenguaje -- y de paso desaparece
// la colision con el alias 'sv' que traia el modulo viejo.
import systemverilog from './hljs-sv.mjs';

for (const [nombre, lang] of Object.entries({ bash, plaintext, python, tcl, systemverilog, vhdl })) {
  hljs.registerLanguage(nombre, lang);
}

export default hljs;
