// promo-demo renderer: frames + original audio -> out/promo-demo.mp4
import { chromium } from 'playwright-core';
import { execFileSync } from 'node:child_process';
import { mkdirSync, rmSync, existsSync } from 'node:fs';

const FPS = 30, TOTAL = 390, W = 1080, H = 1920;
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
  await page.screenshot({ path: `out/frames/F${String(f + 1).padStart(5, '0')}.png`,
    animations: 'disabled' });
  if ((f + 1) % 90 === 0) console.log(`rendered ${f + 1}/${TOTAL}`);
}
await browser.close();

execFileSync('ffmpeg', [
  '-y', '-framerate', String(FPS), '-i', 'out/frames/F%05d.png',
  '-i', 'assets/mixed_audio.wav',
  '-c:v', 'libx264', '-crf', '16', '-preset', 'slow', '-pix_fmt', 'yuv420p',
  '-c:a', 'aac', '-b:a', '192k', '-shortest', '-movflags', '+faststart',
  'out/promo-demo.mp4',
], { stdio: 'inherit' });
console.log('wrote out/promo-demo.mp4');
