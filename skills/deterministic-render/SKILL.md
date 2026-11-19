---
name: deterministic-render
description: Render edits from code (Playwright seekToFrame or Remotion) so every output frame is reproducible from the plan. Use for the build and rebuild loop.
---

# Deterministic render

The owner's brief: hybrid code + assets build, deterministic render, then
QA against the reference. Two supported routes:

## Route A: Playwright seekToFrame (CPU-only, proven in this repo)

HTML/CSS/JS composition -> Playwright loads the page, seeks a JS clock to
each frame number, screenshots -> ffmpeg assembles. This is the route
`examples/kinetic-demo/` uses. Frame N is pure function of the timeline
state: no `Date.now()`, no rAF drift - animations read a `window.__frame`
clock the harness sets.

## Route B: Remotion

React components -> `npx remotion render`. Heavier install; use when the
composition is component-complex. Same rule: all motion derives from
`useCurrentFrame()`.

## Rules

- Everything time-varying reads the frame clock. Wall-clock reads are a
  determinism bug.
- Assets are pinned in the ledger (asset-sourcing). A re-render with the
  same plan and ledger produces identical bytes.
- 2.5D fakes over real 3D on CPU-only boxes (see motion-graphics).
- Export via `tools/encode.sh`: libx264, crf 18, yuv420p, native fps,
  faststart. Vertical sources stay 1080x1920; do not letterbox.
