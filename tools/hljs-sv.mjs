// Gramatica de SystemVerilog + UVM para highlight.js.
//
// Reemplaza al modulo 'verilog' que trae hljs: ese pinta tres cosas (keyword,
// variable, string) y deja en gris justo lo que el curso ensena -- las macros
// `uvm_* y la jerarquia de clases uvm_*. El curso no tiene Verilog-95 puro (el
// DUT y todo el resto es SystemVerilog), asi que no hace falta convivir con el:
// hljs-slim.mjs registra este con los alias sv/svh/v/verilog y listo.
//
// Categorias que emite, ademas de las estandar de hljs:
//   hljs-uvm-macro   `uvm_info, `uvm_component_utils, `uvm_do_with, ...
//   hljs-uvm-type    uvm_component, uvm_subscriber, uvm_tlm_analysis_fifo, ...
//   hljs-uvm-const   UVM_HIGH, UVM_ACTIVE, UVM_NO_ACTION, ...
// Las tres son por patron, no por lista: la libreria UVM tiene ~400 clases y
// otras tantas macros, y una lista cerrada se desactualiza sola.
// El tema que las pinta es css/code.css.

const KEYWORDS = [
  'begin', 'end', 'class', 'endclass', 'extends', 'implements', 'interface', 'endinterface',
  'module', 'endmodule', 'package', 'endpackage', 'program', 'endprogram', 'function',
  'endfunction', 'task', 'endtask', 'modport', 'clocking', 'endclocking', 'checker',
  'endchecker', 'generate', 'endgenerate', 'genvar', 'primitive', 'endprimitive',
  'specify', 'endspecify', 'config', 'endconfig', 'table', 'endtable',
  'virtual', 'pure', 'local', 'protected', 'static', 'automatic', 'const', 'extern',
  'context', 'ref', 'this', 'super', 'new', 'null', 'import', 'export', 'typedef',
  'enum', 'struct', 'union', 'packed', 'tagged', 'parameter', 'localparam', 'defparam',
  'initial', 'final', 'always', 'always_ff', 'always_comb', 'always_latch', 'assign',
  'fork', 'join', 'join_any', 'join_none', 'wait', 'wait_order', 'disable', 'force',
  'release', 'deassign', 'posedge', 'negedge', 'edge', 'repeat', 'forever', 'while',
  'for', 'foreach', 'do', 'if', 'else', 'case', 'casex', 'casez', 'endcase', 'default',
  'return', 'break', 'continue', 'priority', 'unique', 'unique0', 'inside', 'with',
  'randomize', 'rand', 'randc', 'constraint', 'solve', 'before', 'dist', 'randcase',
  'randsequence', 'covergroup', 'endgroup', 'coverpoint', 'bins', 'ignore_bins',
  'illegal_bins', 'cross', 'option', 'type_option', 'assert', 'assume', 'cover',
  'expect', 'property', 'endproperty', 'sequence', 'endsequence', 'first_match',
  'intersect', 'throughout', 'within', 'bind', 'input', 'output', 'inout',
  'timeunit', 'timeprecision', 'defaultclocking',
];

// Tipos de dato. Van aparte de las keywords para que el tema los pueda pintar
// distinto: en una slide de UVM interesa mas ver donde estan los tipos que
// donde esta un `begin`.
const TYPES = [
  'logic', 'bit', 'byte', 'int', 'shortint', 'longint', 'integer', 'reg', 'wire',
  'string', 'void', 'real', 'shortreal', 'realtime', 'time', 'chandle', 'event',
  'signed', 'unsigned', 'genvar', 'supply0', 'supply1', 'tri', 'tri0', 'tri1',
  'triand', 'trior', 'trireg', 'wand', 'wor', 'uwire', 'var',
];

const IDENT = '[A-Za-z_][A-Za-z0-9_]*';

export default function systemverilog(hljs) {
  const NUMBER = {
    scope: 'number',
    relevance: 0,
    variants: [
      // literales dimensionados: 3'b001, 8'hff, 16'd10, 1'bx, 8'b1010_1010, 32'sd5
      { begin: /\b\d[\d_]*\s*'[sS]?[bBoOdDhH][0-9a-fA-FxXzZ?_]+/ },
      // sin tamano: 'hff, 'b1010
      { begin: /'[sS]?[bBoOdDhH][0-9a-fA-FxXzZ?_]+/ },
      // relleno: '0 '1 'x 'z
      { begin: /'[01xXzZ](?![A-Za-z0-9_])/ },
      // decimal / real / con unidad de tiempo: 42, 3.14, 1e6, 10ns
      { begin: /\b\d[\d_]*(?:\.[\d_]+)?(?:[eE][+-]?\d+)?(?:[munpf]?s)?\b/ },
    ],
  };

  return {
    name: 'SystemVerilog',
    aliases: ['sv', 'svh', 'systemverilog', 'verilog', 'v'],
    case_insensitive: false,
    keywords: { keyword: KEYWORDS, type: TYPES },
    contains: [
      hljs.C_LINE_COMMENT_MODE,
      hljs.C_BLOCK_COMMENT_MODE,
      hljs.QUOTE_STRING_MODE,

      // --- UVM ---------------------------------------------------------------
      // El orden importa poco entre reglas que arrancan en posiciones distintas
      // (gana la que empieza antes, no la que este primero), pero `uvm_info y
      // `include arrancan las dos en el backtick: la de UVM va antes a proposito.
      { scope: 'uvm-macro', begin: '`uvm_' + IDENT, relevance: 10 },
      { scope: 'uvm-type', begin: '\\buvm_' + IDENT + '\\b', relevance: 10 },
      { scope: 'uvm-const', begin: /\bUVM_[A-Z0-9_]+\b/, relevance: 10 },

      // Directivas de compilador y macros de usuario: `include `define `ifdef ...
      { scope: 'meta', begin: '`' + IDENT },
      // Tasks y funciones del sistema: $display $sformatf $cast $fatal ...
      { scope: 'built_in', begin: '\\$' + IDENT },

      // class scoreboard extends ... -> el nombre propio, no la clase base
      // (uvm_subscriber ya lo agarro la regla uvm-type de arriba).
      {
        match: [/\b(?:class|package|interface|module|program)\b/, /\s+/, IDENT],
        scope: { 1: 'keyword', 3: 'title' },
      },
      // function [void|tipo] nombre(  /  task nombre(
      {
        match: [
          /\b(?:function|task)\b/, /\s+/,
          /(?:(?:automatic|static)\s+)?/,
          /(?:void\s+|[A-Za-z_][A-Za-z0-9_]*(?:\s*#\s*\([^()]*\))?\s+)?/,
          IDENT,
          /(?=\s*[(;])/,
        ],
        scope: { 1: 'keyword', 3: 'keyword', 4: 'type', 5: 'title' },
      },

      // El parametro de una clase parametrizada es un tipo:
      //   uvm_subscriber #(result_transaction)
      // Se excluye uvm_* para que #(uvm_object) siga cayendo en la regla de UVM,
      // y el lookahead deja pasar de largo formas como #(virtual vtalu_bfm).
      {
        match: [/#\s*\(\s*/, '(?!uvm_)' + IDENT, /(?=\s*[,)])/],
        scope: { 2: 'type' },
      },

      NUMBER,
    ],
  };
}
