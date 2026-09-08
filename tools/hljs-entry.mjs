// plugin.js ya exporta la fabrica ("export default () => Plugin"), que es
// exactamente lo que expone el bundle de reveal como global RevealHighlight.
// Se reexpone tal cual: template.html sigue haciendo plugins: [RevealHighlight]
// sin enterarse de nada.
import fabrica from 'reveal.js/plugin/highlight/plugin.js';
window.RevealHighlight = fabrica;
