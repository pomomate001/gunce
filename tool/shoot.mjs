// Drives the web preview (build/web) in headless Chrome and saves phone-sized screenshots
// for the store: node shoot.mjs <script.json>
// script: { "lang": "tr", "prefs": {"theme": "dawn"}, "steps": [ {"click":[x,y]}, {"wait":800}, {"shot":"home"} ] }
// Coordinates are CSS pixels of a 412x915 viewport; shots are 1080x2400 PNGs in store/raw/<name>-<lang>.png.
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import puppeteer from 'puppeteer-core';

const ROOT = path.resolve(import.meta.dirname, '..');
const WEB = path.join(ROOT, 'build', 'web');
const OUT = path.join(ROOT, 'store', 'raw');
const script = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const TYPES = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png', '.webp': 'image/webp', '.ttf': 'font/ttf', '.otf': 'font/otf', '.css': 'text/css', '.txt': 'text/plain' };

const server = http.createServer((req, res) => {
  const url = decodeURIComponent(req.url.split('?')[0]);
  let file = path.join(WEB, url === '/' ? 'index.html' : url);
  if (!file.startsWith(WEB) || !fs.existsSync(file)) file = path.join(WEB, 'index.html');
  res.writeHead(200, { 'Content-Type': TYPES[path.extname(file)] ?? 'application/octet-stream' });
  fs.createReadStream(file).pipe(res);
}).listen(0);
const port = server.address().port;

const browser = await puppeteer.launch({
  executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
  headless: true,
  args: ['--hide-scrollbars', '--force-color-profile=srgb'],
});
try {
  const page = await browser.newPage();
  await page.setViewport({ width: 412, height: 915, deviceScaleFactor: 2.6215, isMobile: true, hasTouch: false });
  await page.goto(`http://127.0.0.1:${port}/`, { waitUntil: 'load' });
  const prefs = { onboarded: true, locale: script.lang, theme: 'dawn', ...(script.prefs ?? {}) };
  await page.evaluate((p) => {
    localStorage.clear();
    for (const [k, v] of Object.entries(p)) localStorage.setItem(`flutter.${k}`, JSON.stringify(v));
  }, prefs);
  await page.goto(`http://127.0.0.1:${port}/`, { waitUntil: 'load' });
  await new Promise((r) => setTimeout(r, 6000));
  fs.mkdirSync(OUT, { recursive: true });
  for (const step of script.steps) {
    if (step.click) await page.mouse.click(step.click[0], step.click[1]);
    if (step.drag) {
      const [x1, y1, x2, y2] = step.drag;
      await page.mouse.move(x1, y1);
      await page.mouse.down();
      for (let i = 1; i <= 12; i++) await page.mouse.move(x1 + ((x2 - x1) * i) / 12, y1 + ((y2 - y1) * i) / 12);
      await page.mouse.up();
    }
    if (step.wheel) await page.mouse.wheel({ deltaY: step.wheel });
    await new Promise((r) => setTimeout(r, step.wait ?? 900));
    if (step.shot) {
      await page.screenshot({ path: path.join(OUT, `${step.shot}-${script.lang}.png`), clip: { x: 0, y: 0, width: 412, height: 915 } });
      console.log('shot', step.shot);
    }
  }
} finally {
  await browser.close();
  server.close();
}
