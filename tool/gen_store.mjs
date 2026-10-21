// Play Store graphics: feature graphic (1024x500) and captioned phone screenshots (1080x1920).
//   node gen_store.mjs            -> store/feature-graphic.png and store/screenshots/<n>-<lang>.png
// Raw screenshots are read from store/raw/<name>.png (taken on the emulator).
import fs from 'node:fs';
import path from 'node:path';
import { withBrowser, renderHtml } from './lib/render.mjs';
import { mochiSvg } from './gen_moods.mjs';

const ROOT = path.resolve(import.meta.dirname, '..');
const STORE = path.join(ROOT, 'store');
const font = (file) => `data:font/ttf;base64,${fs.readFileSync(path.join(ROOT, 'assets', 'fonts', file)).toString('base64')}`;
const FONTS = `
  @font-face { font-family: Fraunces; font-weight: 600; src: url(${font('Fraunces-600.ttf')}); }
  @font-face { font-family: Nunito; font-weight: 700; src: url(${font('Nunito-700.ttf')}); }
  @font-face { font-family: Nunito; font-weight: 400; src: url(${font('Nunito-400.ttf')}); }`;
const img = (file) => `data:image/png;base64,${fs.readFileSync(file).toString('base64')}`;

// Dawn landscape as plain SVG (mirrors the app's procedural scene).
function landscape(w, h) {
  const ridge = (base, bumps, mountain) => {
    const pts = [];
    for (let i = 0; i <= 120; i++) {
      const x = -0.02 + (1.04 * i) / 120;
      let y = 0;
      for (const [bx, bh, bw] of bumps) {
        const u = (x - bx) / bw;
        if (mountain) {
          const a = Math.sqrt(u * u + 0.0016);
          y = Math.max(y, a >= 1 ? 0 : bh * Math.pow(1 - a, 1.3));
        } else y += bh * Math.exp(-u * u * 2.2);
      }
      pts.push(`${(x * w).toFixed(1)},${((base - y) * h).toFixed(1)}`);
    }
    return `M-4,${h + 4} L${pts.join(' L')} L${w + 4},${h + 4} Z`;
  };
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" width="${w}" height="${h}">
    <defs>
      <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F4C3CF"/><stop offset=".5" stop-color="#FFD8C2"/><stop offset="1" stop-color="#FFF0D4"/></linearGradient>
      <radialGradient id="glow"><stop offset="0" stop-color="#FFD6A0" stop-opacity=".6"/><stop offset=".35" stop-color="#FFD6A0" stop-opacity=".2"/><stop offset="1" stop-color="#FFD6A0" stop-opacity="0"/></radialGradient>
    </defs>
    <rect width="${w}" height="${h}" fill="url(#sky)"/>
    <circle cx="${w * 0.74}" cy="${h * 0.5}" r="${w * 0.3}" fill="url(#glow)"/>
    <circle cx="${w * 0.74}" cy="${h * 0.5}" r="${w * 0.055}" fill="#FFF6DE"/>
    <path d="${ridge(0.74, [[0.12, 0.3, 0.2], [0.42, 0.2, 0.18], [0.86, 0.34, 0.22]], true)}" fill="#EDB8C3"/>
    <path d="${ridge(0.86, [[0.3, 0.27, 0.26], [0.64, 0.17, 0.18], [1.02, 0.25, 0.22]], true)}" fill="#C99AB8"/>
    <path d="${ridge(1.0, [[0.1, 0.12, 0.3], [0.55, 0.08, 0.35], [0.92, 0.11, 0.25]], false)}" fill="#8F6F9F"/>
  </svg>`;
}

const sized = (svg, s) => svg.replace('<svg ', `<svg width="${s}" height="${s}" `);

function featureGraphic(lang) {
  const tagline = lang === 'tr' ? 'Her günün, güzel bir sayfayı hak ediyor.' : 'Every day deserves a beautiful page.';
  return `<html><head><style>${FONTS}
    body{margin:0;width:1024px;height:500px;overflow:hidden;position:relative;font-family:Nunito}
    .bg{position:absolute;inset:0}
    .title{position:absolute;left:64px;top:118px;font-family:Fraunces;font-weight:600;font-size:96px;color:#3A2A3C;letter-spacing:-1px}
    .tag{position:absolute;left:68px;top:238px;font-size:27px;color:#6E5A6B;font-weight:700;width:600px;line-height:1.3}
    .icon{position:absolute;left:68px;top:330px;width:96px;height:96px;border-radius:24px;box-shadow:0 12px 30px rgba(120,60,70,.25)}
    .mochi{position:absolute;bottom:34px}
  </style></head><body>
    <div class="bg">${landscape(1024, 500)}</div>
    <div class="title">Günce</div>
    <div class="tag">${tagline}</div>
    <img class="icon" src="${img(path.join(STORE, 'icon-512.png'))}">
    <div class="mochi" style="left:610px">${sized(mochiSvg('calm'), 120)}</div>
    <div class="mochi" style="left:715px;bottom:60px">${sized(mochiSvg('great'), 160)}</div>
    <div class="mochi" style="left:860px">${sized(mochiSvg('loved'), 120)}</div>
  </body></html>`;
}

const SHOTS = [
  { raw: 'home', bg: ['#FFE3D3', '#F7B9C7'], tr: 'Her güne güzel\nbir sayfa', en: 'A beautiful page\nfor every day' },
  { raw: 'editor', bg: ['#FFF0D4', '#FFC9A8'], tr: 'Fotoğraf, ses\nve çıkartmalar', en: 'Photos, voice notes\nand stickers' },
  { raw: 'mood', bg: ['#E3F4EC', '#A8DCC6'], tr: 'Ruh halini tek\ndokunuşla kaydet', en: 'Log your mood\nwith one tap' },
  { raw: 'stats', bg: ['#EDE5FF', '#C9B6F2'], tr: 'Kendini daha\niyi tanı', en: 'Understand\nyourself better' },
  { raw: 'themes', bg: ['#DDEEFF', '#A9C6FF'], tr: '12 animasyonlu\ntema', en: '12 animated\nthemes' },
  { raw: 'lock', bg: ['#2B2758', '#8E4A7E'], tr: 'PIN ile kilitli,\nsadece senin', en: 'Locked with a PIN,\nonly yours', dark: true },
];

function shotFrame(shot, lang, rawFile) {
  const caption = shot[lang].replace('\n', '<br>');
  return `<html><head><style>${FONTS}
    body{margin:0;width:1080px;height:1920px;overflow:hidden;background:linear-gradient(160deg,${shot.bg[0]},${shot.bg[1]});font-family:Nunito}
    h1{margin:0;position:absolute;top:120px;left:0;right:0;text-align:center;font-family:Fraunces;font-weight:600;font-size:88px;line-height:1.08;color:${shot.dark ? '#FFF4EE' : '#3A2A3C'};letter-spacing:-1px}
    .phone{position:absolute;left:150px;top:420px;width:780px;height:1660px;border-radius:72px;background:#16121C;padding:18px;box-sizing:border-box;box-shadow:0 40px 80px rgba(40,20,40,.28)}
    .phone img{width:100%;border-radius:56px;display:block}
  </style></head><body><h1>${caption}</h1><div class="phone"><img src="${img(rawFile)}"></div></body></html>`;
}

await withBrowser(async (page) => {
  for (const lang of ['tr', 'en']) {
    await renderHtml(page, featureGraphic(lang), path.join(STORE, `feature-graphic-${lang}.png`), 1024, 500);
  }
  const rawDir = path.join(STORE, 'raw');
  const outDir = path.join(STORE, 'screenshots');
  fs.mkdirSync(outDir, { recursive: true });
  for (const [i, shot] of SHOTS.entries()) {
    for (const lang of ['tr', 'en']) {
      const raw = path.join(rawDir, `${shot.raw}-${lang}.png`);
      if (!fs.existsSync(raw)) continue;
      await renderHtml(page, shotFrame(shot, lang, raw), path.join(outDir, `${i + 1}-${shot.raw}-${lang}.png`), 1080, 1920);
    }
  }
});
console.log('done');
