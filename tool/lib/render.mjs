// Shared headless-Chrome renderer for the asset generators.
import puppeteer from 'puppeteer-core';
import fs from 'node:fs';

const CHROME_CANDIDATES = [
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
];

export async function withBrowser(fn) {
  const executablePath = CHROME_CANDIDATES.find((p) => fs.existsSync(p));
  const browser = await puppeteer.launch({
    executablePath,
    headless: true,
    args: ['--hide-scrollbars', '--force-color-profile=srgb', '--font-render-hinting=none'],
  });
  try {
    const page = await browser.newPage();
    return await fn(page);
  } finally {
    await browser.close();
  }
}

/** Renders an SVG string to a transparent PNG/WebP file at size x size pixels. */
export async function renderSvg(page, svg, outPath, size, type = 'png') {
  await page.setViewport({ width: size, height: size, deviceScaleFactor: 1 });
  const sized = svg.replace('<svg ', `<svg width="${size}" height="${size}" `);
  await page.setContent(
    `<html><body style="margin:0;background:transparent;overflow:hidden">${sized}</body></html>`,
  );
  const opts = { path: outPath, omitBackground: true, type };
  if (type === 'webp') opts.quality = 92;
  await page.screenshot(opts);
}

/** Renders arbitrary HTML to an image file (opaque unless transparent=true). */
export async function renderHtml(page, html, outPath, width, height, { transparent = false, scale = 1 } = {}) {
  await page.setViewport({ width, height, deviceScaleFactor: scale });
  await page.setContent(html, { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  await page.screenshot({ path: outPath, omitBackground: transparent, type: outPath.endsWith('.jpg') ? 'jpeg' : 'png' });
}
