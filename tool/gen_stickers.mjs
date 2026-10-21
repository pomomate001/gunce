// Turns Fluent Emoji "Color" SVGs (MIT, Microsoft) into die-cut sticker WebPs with a
// white rim and a soft shadow, and converts the Fluent 3D mood faces to WebP.
//   node gen_stickers.mjs <fluent-src-dir>
// <fluent-src-dir> must contain color/<name>.svg and 3d/<name>.png (see README in tool/).
import fs from 'node:fs';
import path from 'node:path';
import { withBrowser, renderSvg, renderHtml } from './lib/render.mjs';

const ROOT = path.resolve(import.meta.dirname, '..');
const SRC = process.argv[2];
if (!SRC) {
  console.error('usage: node gen_stickers.mjs <fluent-src-dir>');
  process.exit(1);
}
const OUT = path.join(ROOT, 'assets', 'stickers');
const SIZE = 360;

const RIM = `
<filter id="cut" x="-25%" y="-25%" width="150%" height="150%" color-interpolation-filters="sRGB">
  <feGaussianBlur in="SourceAlpha" stdDeviation="0.9" result="b1"/>
  <feComponentTransfer in="b1" result="m1"><feFuncA type="linear" slope="40" intercept="-1.2"/></feComponentTransfer>
  <feGaussianBlur in="SourceAlpha" stdDeviation="1.05" result="b2"/>
  <feComponentTransfer in="b2" result="m2"><feFuncA type="linear" slope="40" intercept="-0.9"/></feComponentTransfer>
  <feGaussianBlur in="m2" stdDeviation="0.7" result="sb"/>
  <feOffset in="sb" dy="0.55" result="so"/>
  <feFlood flood-color="#3B2A3C" flood-opacity="0.22"/><feComposite in2="so" operator="in" result="shadow"/>
  <feFlood flood-color="#3B2A3C" flood-opacity="0.10"/><feComposite in2="m2" operator="in" result="edge"/>
  <feFlood flood-color="#FFFFFF"/><feComposite in2="m1" operator="in" result="rim"/>
  <feMerge><feMergeNode in="shadow"/><feMergeNode in="edge"/><feMergeNode in="rim"/><feMergeNode in="SourceGraphic"/></feMerge>
</filter>`;

function wrap(svgSource) {
  const src = svgSource.replace(/<\?xml[^>]*>/, '').trim();
  const inner = src.replace(/<svg\b([^>]*)>/, (m, attrs) => {
    const clean = attrs.replace(/\s(width|height|x|y)="[^"]*"/g, '');
    return `<svg x="0" y="0" width="32" height="32"${clean}>`;
  });
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="-4 -4 40 40"><defs>${RIM}</defs><g filter="url(#cut)">${inner}</g></svg>`;
}

const idOf = (file) => path.basename(file, path.extname(file)).replace(/-/g, '_');

await withBrowser(async (page) => {
  fs.mkdirSync(OUT, { recursive: true });
  const files = fs.readdirSync(path.join(SRC, 'color')).filter((f) => f.endsWith('.svg')).sort();
  const thumbs = [];
  for (const f of files) {
    const svg = wrap(fs.readFileSync(path.join(SRC, 'color', f), 'utf8'));
    await renderSvg(page, svg, path.join(OUT, `${idOf(f)}.webp`), SIZE, 'webp');
    thumbs.push(svg.replace('<svg ', '<svg width="92" height="92" '));
  }
  // 3D mood faces: straight conversion to WebP.
  const moodDir = path.join(ROOT, 'assets', 'moods', 'fluent');
  fs.mkdirSync(moodDir, { recursive: true });
  for (const f of fs.readdirSync(path.join(SRC, '3d')).filter((f) => f.endsWith('.png'))) {
    const b64 = fs.readFileSync(path.join(SRC, '3d', f)).toString('base64');
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256"><image href="data:image/png;base64,${b64}" width="256" height="256"/></svg>`;
    await renderSvg(page, svg, path.join(moodDir, `${idOf(f)}.webp`), 256, 'webp');
  }
  const sheet = `<html><body style="margin:0;padding:12px;background:#F4EEE6;display:flex;flex-wrap:wrap;gap:4px">${thumbs
    .slice(0, 60)
    .join('')}</body></html>`;
  await renderHtml(page, sheet, path.join(import.meta.dirname, 'out', 'stickers_preview.png'), 1000, 640);
});
console.log('done');
