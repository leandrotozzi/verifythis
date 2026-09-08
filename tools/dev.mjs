// Servidor estatico + rebuild automatico. Solo para editar: el deck ya publicado
// se abre con doble clic, sin servidor.
import { createServer } from 'node:http';
import { createReadStream } from 'node:fs';
import { stat, readdir } from 'node:fs/promises';
import { watch } from 'node:fs';
import { spawn } from 'node:child_process';
import path from 'node:path';

const PORT = Number(process.env.PORT) || 8000;
const TYPES = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.css': 'text/css',
  '.md': 'text/markdown; charset=utf-8', '.json': 'application/json', '.svg': 'image/svg+xml',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.gif': 'image/gif',
  '.woff': 'font/woff', '.woff2': 'font/woff2', '.ttf': 'font/ttf', '.eot': 'application/vnd.ms-fontobject',
};

const build = () => new Promise(res => {
  spawn(process.execPath, ['tools/build.mjs'], { stdio: 'inherit' }).on('close', res);
});

createServer(async (req, res) => {
  const url = decodeURIComponent(req.url.split('?')[0]);
  let file = path.join(process.cwd(), url === '/' ? 'index.html' : url);
  // no salir del directorio del proyecto
  if (!file.startsWith(process.cwd())) { res.writeHead(403).end(); return; }
  try {
    if ((await stat(file)).isDirectory()) file = path.join(file, 'index.html');
    res.writeHead(200, { 'content-type': TYPES[path.extname(file)] ?? 'application/octet-stream', 'cache-control': 'no-store' });
    createReadStream(file).pipe(res);
  } catch {
    res.writeHead(404, { 'content-type': 'text/plain' }).end(`404 ${url}`);
  }
}).listen(PORT, () => console.log(`\n  http://localhost:${PORT}\n`));

await build();
let timer;
for (const dir of ['slides', 'code', 'tools', 'css']) {
  watch(dir, { recursive: true }, () => {
    clearTimeout(timer);
    timer = setTimeout(build, 120);
  });
}
console.log('watching slides/ code/ tools/ css/ — Ctrl+C para salir');
