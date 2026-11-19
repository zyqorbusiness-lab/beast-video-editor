// Deterministic frame-by-frame renderer (skills/deterministic-render, Route A).
// The composition reads window.__frame only; wall-clock reads are forbidden.
// Usage: npm install && npm run render
// Output: out/frames/F*.png -> out/kinetic-demo.mp4 (1080x1920, 30fps)
import { chromium } from 'playwright-core';
import { execFileSync } from 'node:child_process';
import { mkdirSync, rmSync, existsSync } from 'node:fs';

const FPS = 30;
const DURATION_S = 8;
const TOTAL = FPS * DURATION_S;
const W = 1080, H = 1920;
const CHROME = process.env.CHROME_PATH || '/usr/bin/google-chrome';

rmSync('out', { recursive: true, force: true });
mkdirSync('out/frames', { recursive: true });

const browser = await chromium.launch({
  executablePath: existsSync(CHROME) ? CHROME : undefined,
  args: ['--no-sandbox', '--disable-dev-shm-usage', '--force-color-profile=srgb'],
});
const page = await browser.newPage({ viewport: { width: W, height: H } });
await page.goto(new URL('./composition.html', import.meta.url).href);
await page.waitForFunction(() => window.__ready === true);

for (let f = 0; f < TOTAL; f++) {
  await page.evaluate((n) => window.__setFrame(n), f);
  const name = `out/frames/F${String(f + 1).padStart(5, '0')}.png`;
  await page.screenshot({ path: name, animations: 'disabled' });
  if ((f + 1) % 60 === 0) console.log(`rendered ${f + 1}/${TOTAL}`);
}
await browser.close();

execFileSync('ffmpeg', [
  '-y', '-framerate', String(FPS), '-i', 'out/frames/F%05d.png',
  '-c:v', 'libx264', '-crf', '18', '-pix_fmt', 'yuv420p',
  '-movflags', '+faststart', 'out/kinetic-demo.mp4',
], { stdio: 'inherit' });
console.log('wrote out/kinetic-demo.mp4');
