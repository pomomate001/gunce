// Generates the original "Mochi" mood character packs (mochi, bear, bunny, pup)
// as SVG, then renders them to transparent WebP assets for the app.
//   node gen_moods.mjs [--preview-only]
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { withBrowser, renderSvg, renderHtml } from './lib/render.mjs';

const ROOT = path.resolve(import.meta.dirname, '..');
const OUT_ASSETS = path.join(ROOT, 'assets', 'moods');
const OUT_SVG = path.join(import.meta.dirname, 'out', 'moods');
const SIZE = 320;

export const MOODS = ['great', 'happy', 'loved', 'calm', 'meh', 'anxious', 'sad', 'angry'];

// Mood colours double as the app-wide mood palette (see lib/data/mood.dart).
export const MOOD_COLORS = {
  great: '#FFC44D',
  happy: '#FFA466',
  loved: '#FF8DAA',
  calm: '#79D2B0',
  meh: '#B4BDD6',
  anxious: '#B09CEB',
  sad: '#78B4F0',
  angry: '#FF7466',
};

const INK = '#35293A';

function hexToRgb(hex) {
  const n = parseInt(hex.slice(1), 16);
  return [(n >> 16) & 255, (n >> 8) & 255, n & 255];
}
function rgbToHex([r, g, b]) {
  return '#' + [r, g, b].map((v) => Math.round(Math.max(0, Math.min(255, v))).toString(16).padStart(2, '0')).join('');
}
/** amt > 0 mixes towards white, amt < 0 towards a warm dark. */
function shade(hex, amt) {
  const c = hexToRgb(hex);
  const target = amt >= 0 ? [255, 255, 255] : [40, 22, 40];
  const t = Math.abs(amt);
  return rgbToHex(c.map((v, i) => v + (target[i] - v) * t));
}

const BODY_PATH = 'M100,40 C151,40 182,76 182,121 C182,157 149,175 100,175 C51,175 18,157 18,121 C18,76 49,40 100,40Z';

function gradientDefs(id, base) {
  return `
  <radialGradient id="${id}" cx="0.36" cy="0.28" r="0.9">
    <stop offset="0" stop-color="${shade(base, 0.42)}"/>
    <stop offset="0.5" stop-color="${base}"/>
    <stop offset="1" stop-color="${shade(base, -0.16)}"/>
  </radialGradient>`;
}

function body(base, id) {
  return `
  <path d="${BODY_PATH}" fill="url(#${id})" stroke="${shade(base, -0.28)}" stroke-width="3"/>
  <ellipse cx="66" cy="70" rx="17" ry="9" transform="rotate(-32 66 70)" fill="#fff" opacity="0.5"/>
  <circle cx="88" cy="56" r="4" fill="#fff" opacity="0.45"/>`;
}

// ---------- face parts ----------
const EYE_L = 74;
const EYE_R = 126;

function dotEye(x, y, s = 1) {
  return `
  <ellipse cx="${x}" cy="${y}" rx="${8.5 * s}" ry="${10.5 * s}" fill="${INK}"/>
  <circle cx="${x + 2.8 * s}" cy="${y - 3.8 * s}" r="${3.2 * s}" fill="#fff"/>
  <circle cx="${x - 2.6 * s}" cy="${y + 3.6 * s}" r="${1.4 * s}" fill="#fff" opacity="0.9"/>`;
}
function arcEye(x, y, up = true) {
  // up=true -> ^ (laughing), up=false -> ‿ (content, closed)
  const d = up ? `M${x - 10},${y + 4} Q${x},${y - 9} ${x + 10},${y + 4}` : `M${x - 10},${y - 2} Q${x},${y + 8} ${x + 10},${y - 2}`;
  return `<path d="${d}" fill="none" stroke="${INK}" stroke-width="5.5" stroke-linecap="round"/>`;
}
function heartEye(x, y) {
  const s = 1.15;
  const p = `M${x},${y + 9 * s} C${x - 14 * s},${y} ${x - 11 * s},${y - 11 * s} ${x - 5 * s},${y - 10 * s} C${x - 2 * s},${y - 9.5 * s} ${x},${y - 7 * s} ${x},${y - 5 * s} C${x},${y - 7 * s} ${x + 2 * s},${y - 9.5 * s} ${x + 5 * s},${y - 10 * s} C${x + 11 * s},${y - 11 * s} ${x + 14 * s},${y} ${x},${y + 9 * s}Z`;
  return `
  <path d="${p}" fill="#FF4F72" stroke="#D93A5C" stroke-width="1.5" stroke-linejoin="round"/>
  <ellipse cx="${x - 5}" cy="${y - 5}" rx="3" ry="2" fill="#fff" opacity="0.8"/>`;
}
function lidEye(x, y) {
  // unimpressed half-lidded eye
  return `
  <path d="M${x - 9},${y - 1} A9,9.5 0 0 0 ${x + 9},${y - 1} Z" fill="${INK}"/>
  <path d="M${x - 11},${y - 1} L${x + 11},${y - 1}" stroke="${INK}" stroke-width="4" stroke-linecap="round"/>
  <circle cx="${x + 3}" cy="${y + 3}" r="2" fill="#fff"/>`;
}
function wideEye(x, y) {
  return `
  <circle cx="${x}" cy="${y}" r="11.5" fill="#fff" stroke="${INK}" stroke-width="3.5"/>
  <circle cx="${x}" cy="${y + 1.5}" r="5" fill="${INK}"/>
  <circle cx="${x + 1.6}" cy="${y - 0.4}" r="1.6" fill="#fff"/>`;
}
function brows(kind) {
  const w = kind === 'angry' ? 6 : 4.5;
  let l, r;
  if (kind === 'sad') {
    l = `M${EYE_L - 13},${92} Q${EYE_L - 2},${90} ${EYE_L + 9},${84}`;
    r = `M${EYE_R + 13},${92} Q${EYE_R + 2},${90} ${EYE_R - 9},${84}`;
  } else if (kind === 'worried') {
    l = `M${EYE_L - 12},${88} Q${EYE_L},${86} ${EYE_L + 9},${82}`;
    r = `M${EYE_R + 12},${88} Q${EYE_R},${86} ${EYE_R - 9},${82}`;
  } else {
    l = `M${EYE_L - 13},${85} L${EYE_L + 10},${96}`;
    r = `M${EYE_R + 13},${85} L${EYE_R - 10},${96}`;
  }
  return `<path d="${l}" fill="none" stroke="${INK}" stroke-width="${w}" stroke-linecap="round"/>
  <path d="${r}" fill="none" stroke="${INK}" stroke-width="${w}" stroke-linecap="round"/>`;
}
function cheeks(opacity, color = '#FF6B8B', dy = 0) {
  return `
  <ellipse cx="52" cy="${131 + dy}" rx="12" ry="7.5" fill="${color}" opacity="${opacity}"/>
  <ellipse cx="148" cy="${131 + dy}" rx="12" ry="7.5" fill="${color}" opacity="${opacity}"/>`;
}

function mouth(kind, dy = 0) {
  const y = 131 + dy;
  switch (kind) {
    case 'open':
      return `
  <clipPath id="mclip${dy}"><path d="M83,${y - 3} Q100,${y} 117,${y - 3} Q115,${y + 20} 100,${y + 20} Q85,${y + 20} 83,${y - 3}Z"/></clipPath>
  <path d="M83,${y - 3} Q100,${y} 117,${y - 3} Q115,${y + 20} 100,${y + 20} Q85,${y + 20} 83,${y - 3}Z" fill="#5B2436"/>
  <ellipse cx="100" cy="${y + 19}" rx="12" ry="8" fill="#FF7E95" clip-path="url(#mclip${dy})"/>`;
    case 'smile':
      return `<path d="M87,${y} Q100,${y + 13} 113,${y}" fill="none" stroke="${INK}" stroke-width="5" stroke-linecap="round"/>`;
    case 'softsmile':
      return `<path d="M91,${y + 1} Q100,${y + 8} 109,${y + 1}" fill="none" stroke="${INK}" stroke-width="4.5" stroke-linecap="round"/>`;
    case 'loved':
      return `
  <path d="M89,${y} Q100,${y + 2} 111,${y} Q109,${y + 13} 100,${y + 13} Q91,${y + 13} 89,${y}Z" fill="#5B2436"/>
  <ellipse cx="100" cy="${y + 10}" rx="6" ry="3.4" fill="#FF7E95"/>`;
    case 'flat':
      return `<path d="M89,${y + 4} L111,${y + 4}" stroke="${INK}" stroke-width="5" stroke-linecap="round"/>`;
    case 'wavy':
      return `<path d="M83,${y + 6} q4.25,-6 8.5,0 t8.5,0 t8.5,0 t8.5,0" fill="none" stroke="${INK}" stroke-width="4.5" stroke-linecap="round" stroke-linejoin="round"/>`;
    case 'frown':
      return `<path d="M88,${y + 11} Q100,${y} 112,${y + 11}" fill="none" stroke="${INK}" stroke-width="5" stroke-linecap="round"/>`;
    case 'grr':
      return `
  <path d="M85,${y + 12} Q100,${y - 1} 115,${y + 12} Z" fill="#5B2436" stroke="${INK}" stroke-width="4" stroke-linejoin="round"/>
  <path d="M91,${y + 9.5} L109,${y + 9.5}" stroke="#fff" stroke-width="3" stroke-linecap="round"/>`;
  }
  return '';
}

function extras(mood) {
  switch (mood) {
    case 'loved':
      return `<path d="M160,58 C150,52 151,42 157,42 C159.5,42 160.5,44 161,45.5 C161.5,44 162.5,42 165,42 C171,42 172,52 160,58Z" fill="#FF4F72" stroke="#D93A5C" stroke-width="1.5" transform="rotate(12 160 50)"/>`;
    case 'anxious':
      return `<path d="M152,62 C152,62 143,74 143,80 A9,9 0 0 0 161,80 C161,74 152,62 152,62Z" fill="#A7DCFF" stroke="#5FA8DD" stroke-width="2.5"/>
  <ellipse cx="149" cy="79" rx="2.2" ry="3.4" fill="#fff" opacity="0.9"/>`;
    case 'sad':
      return `<path d="M${EYE_R + 4},116 C${EYE_R + 4},116 ${EYE_R - 3},126 ${EYE_R - 3},131 A7,7 0 0 0 ${EYE_R + 11},131 C${EYE_R + 11},126 ${EYE_R + 4},116 ${EYE_R + 4},116Z" fill="#A7DCFF" stroke="#5FA8DD" stroke-width="2"/>`;
    case 'angry':
      return `<g stroke="#E0384B" stroke-width="4.5" stroke-linecap="round" fill="none">
    <path d="M147,57 Q154,57 154,50"/><path d="M161,50 Q161,57 168,57"/>
    <path d="M168,64 Q161,64 161,71"/><path d="M154,71 Q154,64 147,64"/></g>`;
    case 'great':
      return `<path d="M163,46 L166,54 L174,57 L166,60 L163,68 L160,60 L152,57 L160,54Z" fill="#FFE27A" stroke="#E8A93A" stroke-width="2" stroke-linejoin="round"/>
  <path d="M40,62 L42,67 L47,69 L42,71 L40,76 L38,71 L33,69 L38,67Z" fill="#FFE27A" stroke="#E8A93A" stroke-width="1.6" stroke-linejoin="round"/>`;
  }
  return '';
}

/** Face for a mood. `dy` shifts the mouth for characters with a snout/nose. */
function face(mood, { dy = 0, cheekColor } = {}) {
  const y = 110;
  switch (mood) {
    case 'great':
      return cheeks(0.42, cheekColor) + arcEye(EYE_L, y, true) + arcEye(EYE_R, y, true) + mouth('open', dy);
    case 'happy':
      return cheeks(0.38, cheekColor) + dotEye(EYE_L, y) + dotEye(EYE_R, y) + mouth('smile', dy);
    case 'loved':
      return cheeks(0.5, cheekColor) + heartEye(EYE_L, y) + heartEye(EYE_R, y) + mouth('loved', dy);
    case 'calm':
      return cheeks(0.32, cheekColor) + arcEye(EYE_L, y + 2, false) + arcEye(EYE_R, y + 2, false) + mouth('softsmile', dy);
    case 'meh':
      return cheeks(0.18, cheekColor) + lidEye(EYE_L, y) + lidEye(EYE_R, y) + mouth('flat', dy);
    case 'anxious':
      return cheeks(0.16, cheekColor) + brows('worried') + wideEye(EYE_L, y + 2) + wideEye(EYE_R, y + 2) + mouth('wavy', dy);
    case 'sad':
      return cheeks(0.14, cheekColor) + brows('sad') + dotEye(EYE_L, y + 3, 0.85) + dotEye(EYE_R, y + 3, 0.85) + mouth('frown', dy);
    case 'angry':
      return cheeks(0.3, '#FF4A4A') + brows('angry') + dotEye(EYE_L, y + 3, 0.85) + dotEye(EYE_R, y + 3, 0.85) + mouth('grr', dy);
  }
  return '';
}

let svgSeq = 0;
function svgWrap(inner, defs = '') {
  const k = `_${++svgSeq}`;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200"><defs>${defs}</defs>${inner}</svg>`;
  return svg.replace(/id="([^"]+)"/g, `id="$1${k}"`).replace(/url\(#([^)]+)\)/g, `url(#$1${k})`);
}

// ---------- packs ----------
const packs = {
  mochi(mood) {
    const base = MOOD_COLORS[mood];
    return svgWrap(body(base, 'g') + face(mood) + extras(mood), gradientDefs('g', base));
  },

  bear(mood) {
    const base = '#C98F62';
    const inner = '#F2C9A6';
    const ears = `
  <circle cx="46" cy="58" r="25" fill="url(#g)" stroke="${shade(base, -0.28)}" stroke-width="3"/>
  <circle cx="154" cy="58" r="25" fill="url(#g)" stroke="${shade(base, -0.28)}" stroke-width="3"/>
  <circle cx="47" cy="59" r="13" fill="${inner}"/>
  <circle cx="153" cy="59" r="13" fill="${inner}"/>`;
    const snout = `
  <ellipse cx="100" cy="139" rx="29" ry="21" fill="#F4DCC4"/>
  <ellipse cx="100" cy="128" rx="9" ry="6.5" fill="${INK}"/>
  <ellipse cx="97" cy="126" rx="3" ry="1.8" fill="#fff" opacity="0.7"/>`;
    return svgWrap(ears + body(base, 'g') + snout + face(mood, { dy: 9 }) + extras(mood), gradientDefs('g', base));
  },

  bunny(mood) {
    const base = '#F7F0E8';
    const line = '#D8C9BB';
    const ears = `
  <g transform="rotate(-14 72 40)"><ellipse cx="72" cy="36" rx="17" ry="40" fill="url(#g)" stroke="${line}" stroke-width="3"/>
  <ellipse cx="72" cy="40" rx="8" ry="28" fill="#FFB8C8"/></g>
  <g transform="rotate(14 128 40)"><ellipse cx="128" cy="36" rx="17" ry="40" fill="url(#g)" stroke="${line}" stroke-width="3"/>
  <ellipse cx="128" cy="40" rx="8" ry="28" fill="#FFB8C8"/></g>`;
    const nose = `<path d="M94,124 Q100,121 106,124 Q100,131 94,124Z" fill="#FF8FA8"/>`;
    const inner = ears + `<path d="${BODY_PATH}" fill="url(#g)" stroke="${line}" stroke-width="3"/>
  <ellipse cx="66" cy="74" rx="17" ry="9" transform="rotate(-32 66 74)" fill="#fff" opacity="0.7"/>` + nose + face(mood, { dy: 6, cheekColor: '#FF7FA0' }) + extras(mood);
    return svgWrap(`<g transform="translate(100 116) scale(0.86) translate(-100 -104)">${inner}</g>`, `
  <radialGradient id="g" cx="0.36" cy="0.28" r="0.9">
    <stop offset="0" stop-color="#FFFFFF"/><stop offset="0.6" stop-color="${base}"/><stop offset="1" stop-color="#E6D8CA"/>
  </radialGradient>`);
  },

  pup(mood) {
    const base = '#F5DDB5';
    const brown = '#A7703F';
    const earL = `<path d="M62,50 C42,36 12,44 10,78 C8,104 26,116 38,104 C46,95 50,78 66,62Z" fill="${brown}" stroke="${shade(brown, -0.3)}" stroke-width="3" stroke-linejoin="round"/>`;
    const earR = `<path d="M138,50 C158,36 188,44 190,78 C192,104 174,116 162,104 C154,95 150,78 134,62Z" fill="${brown}" stroke="${shade(brown, -0.3)}" stroke-width="3" stroke-linejoin="round"/>`;
    const patch = `<ellipse cx="${EYE_R + 1}" cy="105" rx="19" ry="17" fill="#E9BC88" opacity="0.9"/>`;
    const nose = `
  <ellipse cx="100" cy="125" rx="10" ry="7" fill="${INK}"/>
  <ellipse cx="97" cy="122.5" rx="3.4" ry="2" fill="#fff" opacity="0.75"/>`;
    return svgWrap(body(base, 'g') + patch + earL + earR + nose + face(mood, { dy: 8 }) + extras(mood), gradientDefs('g', base));
  },
};

export const PACKS = Object.keys(packs);

/** Mochi character SVG for other generators (icon, store art). */
export function mochiSvg(mood, color) {
  const base = color ?? MOOD_COLORS[mood];
  return svgWrap(body(base, 'g') + face(mood) + extras(mood), gradientDefs('g', base));
}

async function main() {
  const previewOnly = process.argv.includes('--preview-only');
  fs.mkdirSync(OUT_SVG, { recursive: true });
  const rows = [];
  for (const pack of PACKS) {
    const cells = [];
    for (const mood of MOODS) {
      const svg = packs[pack](mood);
      fs.writeFileSync(path.join(OUT_SVG, `${pack}_${mood}.svg`), svg);
      cells.push(`<div class="c">${svg.replace('<svg ', '<svg width="110" height="110" ')}<span>${mood}</span></div>`);
    }
    rows.push(`<div class="r"><b>${pack}</b>${cells.join('')}</div>`);
  }
  const sheet = `<html><body style="margin:0;padding:16px;background:#FFF8F1;font:12px sans-serif">
  <style>.r{display:flex;align-items:center;gap:6px;margin-bottom:6px}.r b{width:56px}.c{display:flex;flex-direction:column;align-items:center}
  .dark{background:#1B1F3B;padding:10px;border-radius:16px}</style>${rows.join('')}
  <div class="r dark">${MOODS.map((m) => packs.mochi(m).replace('<svg ', '<svg width="56" height="56" ')).join('')}
  ${MOODS.map((m) => packs.bunny(m).replace('<svg ', '<svg width="56" height="56" ')).join('')}</div>
  <div class="r">${MOODS.map((m) => packs.mochi(m).replace('<svg ', '<svg width="28" height="28" ')).join('')}
  ${MOODS.map((m) => packs.pup(m).replace('<svg ', '<svg width="28" height="28" ')).join('')}</div></body></html>`;

  await withBrowser(async (page) => {
    await renderHtml(page, sheet, path.join(import.meta.dirname, 'out', 'moods_preview.png'), 1010, 640);
    if (previewOnly) return;
    for (const pack of PACKS) {
      const dir = path.join(OUT_ASSETS, pack);
      fs.mkdirSync(dir, { recursive: true });
      for (const mood of MOODS) {
        await renderSvg(page, packs[pack](mood), path.join(dir, `${mood}.webp`), SIZE, 'webp');
      }
    }
  });
  console.log('done');
}

if (path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
