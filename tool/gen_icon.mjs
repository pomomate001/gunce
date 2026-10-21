// App icon: adaptive layers + legacy mipmaps + Play Store 512px + splash icon.
//   node gen_icon.mjs            -> writes Android resources and store/icon-512.png
//   node gen_icon.mjs --preview  -> writes out/icon_preview.png only
import fs from 'node:fs';
import path from 'node:path';
import { withBrowser, renderSvg, renderHtml } from './lib/render.mjs';
import { mochiSvg } from './gen_moods.mjs';

const ROOT = path.resolve(import.meta.dirname, '..');
const RES = path.join(ROOT, 'android', 'app', 'src', 'main', 'res');

// 108x108 adaptive canvas; the Mochi sits inside the 66dp safe circle.
const BG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#FFC3A0"/><stop offset="0.55" stop-color="#F7907A"/><stop offset="1" stop-color="#E56373"/>
    </linearGradient>
    <radialGradient id="sun" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0" stop-color="#FFF6E4" stop-opacity="0.75"/><stop offset="0.6" stop-color="#FFF1DC" stop-opacity="0.25"/><stop offset="1" stop-color="#FFF1DC" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="108" height="108" fill="url(#bg)"/>
  <circle cx="54" cy="50" r="40" fill="url(#sun)"/>
  <path d="M0,86 C20,78 38,82 54,86 C72,90 90,80 108,84 L108,108 L0,108Z" fill="#FFFFFF" opacity="0.16"/>
</svg>`;

const mochi = (mood, color) => mochiSvg(mood, color).replace(/^<svg[^>]*>/, '').replace(/<\/svg>$/, '');

// Foreground: a cream Mochi peeking over an open diary, with a sparkle.
const BOOK = `<g transform="translate(54 75)">
    <path d="M-31,-3 Q-15,-9 0,-4 Q15,-9 31,-3 L31,13 Q15,7 0,12 Q-15,7 -31,13Z" fill="#B9405A"/>
    <path d="M-29,-6 Q-14,-12 0,-6 L0,10 Q-14,4 -29,10Z" fill="#FFFDF8"/>
    <path d="M29,-6 Q14,-12 0,-6 L0,10 Q14,4 29,10Z" fill="#FFF6EA"/>
    <path d="M0,-6 L0,10" stroke="#E9CFC4" stroke-width="0.8"/>
    <path d="M-23,-3 Q-13,-7 -5,-3 M-23,1.6 Q-13,-2.4 -5,1.6 M-23,6.2 Q-15,2.8 -9,6.2 M5,-3 Q13,-7 23,-3 M5,1.6 Q13,-2.4 23,1.6" stroke="#F1C7BC" stroke-width="1.1" fill="none" stroke-linecap="round"/>
    <path d="M18,-9 L18,3 L21,0.6 L24,3 L24,-8.2" fill="#FFC44D"/>
  </g>`;
const FG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">
  <g transform="translate(22.5 15) scale(0.315)">${mochi('happy', '#FFF6EC')}</g>
  ${BOOK}
  <path d="M80,24 L81.8,29 L87,30.8 L81.8,32.6 L80,37.6 L78.2,32.6 L73,30.8 L78.2,29Z" fill="#FFF8E6"/>
  <path d="M28,34 L29,36.6 L31.6,37.6 L29,38.6 L28,41.2 L27,38.6 L24.4,37.6 L27,36.6Z" fill="#FFF8E6" opacity="0.85"/>
</svg>`;

const MONO = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">
  <g transform="translate(22.5 15) scale(0.315)">
    <path d="M100,40 C151,40 182,76 182,121 C182,157 149,175 100,175 C51,175 18,157 18,121 C18,76 49,40 100,40Z" fill="#000"/>
  </g>
  <g transform="translate(54 75)"><path d="M-31,-6 Q-15,-12 0,-6 Q15,-12 31,-6 L31,13 Q15,7 0,12 Q-15,7 -31,13Z" fill="#000"/></g>
</svg>`;

const layered = (bg, fg) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">${bg.replace(/^<svg[^>]*>|<\/svg>$/g, '')}${fg.replace(/^<svg[^>]*>|<\/svg>$/g, '')}</svg>`;

/** Legacy/store icon: the adaptive layers cropped to the visible 72dp area, rounded. */
function flat(radius) {
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="18 18 72 72">
    <defs><clipPath id="r"><rect x="18" y="18" width="72" height="72" rx="${radius}"/></clipPath></defs>
    <g clip-path="url(#r)">${layered(BG, FG).replace(/^<svg[^>]*>|<\/svg>$/g, '')}</g></svg>`;
}

const DENSITIES = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };

await withBrowser(async (page) => {
  fs.mkdirSync(path.join(import.meta.dirname, 'out'), { recursive: true });
  const preview = `<html><body style="margin:0;padding:24px;background:#EEE;display:flex;gap:28px;align-items:center">
    ${flat(16).replace('<svg ', '<svg width="192" height="192" ')}
    <div style="width:192px;height:192px;border-radius:50%;overflow:hidden">${layered(BG, FG).replace('<svg ', '<svg width="266" height="266" style="margin:-37px" ')}</div>
    ${flat(16).replace('<svg ', '<svg width="48" height="48" ')}
    <div style="background:#1B1F3B;padding:16px;border-radius:16px">${flat(16).replace('<svg ', '<svg width="64" height="64" ')}</div>
  </body></html>`;
  await renderHtml(page, preview, path.join(import.meta.dirname, 'out', 'icon_preview.png'), 720, 260);
  if (process.argv.includes('--preview')) return;

  for (const [d, k] of Object.entries(DENSITIES)) {
    const dir = path.join(RES, `mipmap-${d}`);
    fs.mkdirSync(dir, { recursive: true });
    await renderSvg(page, BG, path.join(dir, 'ic_launcher_background.png'), Math.round(108 * k));
    await renderSvg(page, FG, path.join(dir, 'ic_launcher_foreground.png'), Math.round(108 * k));
    await renderSvg(page, MONO, path.join(dir, 'ic_launcher_monochrome.png'), Math.round(108 * k));
    await renderSvg(page, flat(16), path.join(dir, 'ic_launcher.png'), Math.round(48 * k));
    await renderSvg(page, flat(36), path.join(dir, 'ic_launcher_round.png'), Math.round(48 * k));
    // Android 12+ splash: icon shown inside a 160dp circle, 240dp canvas.
    const splashDir = path.join(RES, `drawable-${d}`);
    fs.mkdirSync(splashDir, { recursive: true });
    await renderSvg(page, FG, path.join(splashDir, 'splash_icon.png'), Math.round(240 * k * 0.75));
  }
  const store = path.join(ROOT, 'store');
  fs.mkdirSync(store, { recursive: true });
  await renderSvg(page, flat(0), path.join(store, 'icon-512.png'), 512);
});
console.log('done');
