# kinetic-demo

A code-only kinetic typography study, rendered deterministically to a real
MP4. It applies (and cites) the measured numbers from
`../../docs/reference-analysis/01-metros-kinetic-typography.md`:
two-family type, 4-frame word pops, ~15-frame A/B alternation, a 3-frame
white flash on the scene cut, and a 90-frame end-card hold.

## Run

```bash
npm install   # installs playwright-core only (no browser download)
npm run render
```

Requires a Chrome/Chromium binary (default `/usr/bin/google-chrome`;
override with `CHROME_PATH`) and ffmpeg. Output: `out/kinetic-demo.mp4`
(1080x1920, 30fps, 8s, silent).

## Determinism

All motion derives from `window.__frame`, set by the renderer per frame.
There are no wall-clock reads. Re-running the render reproduces the same
frames.

## Honest scope

This demo shows the technique set on original text. It does not recreate
any reference reel, and it contains no reference footage, fonts, or audio
(silent by design - audio sync is covered by `skills/audio-sync`).
