# beast-video-editor

A reference-driven video editing toolkit: deconstruct the best reels
frame-by-frame at their native cadence, encode their techniques as skills,
and rebuild edits deterministically from code. Free tools only
(Linux/Android), CPU-friendly, output that reads hand-made - never
AI-generated.

Built from real study, not theory: five top reels were deconstructed from
native-fps frame extractions (no skipped or duplicated frames) and every
skill cites its evidence. Per-reel extraction counts and viewing status:
`docs/reference-analysis/00-overview.md`.

## What's inside

- `skills/` - ten craft skills (deconstruction, colour, kinetic type,
  captions, motion graphics, audio sync, planning, asset sourcing,
  deterministic render, QA). Each has triggers, measured numbers, and
  rules. Index: `SKILLS.md`.
- `tools/` - runnable scripts: preflight checks, labeled frame extraction,
  audio onset detection, motion measurement (template tracking + easing
  fit), QA contact sheets, side-by-side [ref|render] QA with numeric drift,
  export encoding.
- `examples/kinetic-demo/` - a code-only kinetic typography demo that
  renders to a real MP4. Clone -> `npm install` -> render.
- `examples/promo-demo/` - an original end-to-end promo: colour system,
  word-by-word type, motion graphics, and a synthesized audio bed synced
  within +/-1 frame. Renders to a real MP4 with sound.
- `examples/reference-study/` - the frame-level studies that ground the
  skills (words and numbers only - no reference footage).
- `docs/` - WORKFLOW (the end-to-end process), LICENSING (analysis vs
  redistribution), TESTING (what is verified and what is not).

## Quick start

```bash
# Requirements: ffmpeg, python3, node 18+
tools/preflight.sh                    # verify your environment (+ asset ledger)

# Study a reference (extraction defaults to the video's native fps)
tools/extract_reference.sh reel.mp4 /tmp/study/reel
tools/audio_events.py /tmp/study/reel          # onsets on the extraction timeline
# ... view every contact sheet in /tmp/study/reel/contact_sheets/ ...

# After rendering your recreation, build side-by-side QA sheets:
tools/qa_sheets.sh path/to/recreation.mp4 /tmp/study/reel

# Build the demo
cd examples/kinetic-demo && npm install && npm run render
```

## The loop

Deconstruct (reference-deconstruction) -> plan (edit-planning) -> source
(asset-sourcing) -> build (kinetic-typography / captions / motion-graphics,
colour-theory, audio-sync) -> render (deterministic-render) -> verify
(qa-and-delivery). Full detail in `docs/WORKFLOW.md`.

## Licence posture

This repo teaches technique. Reference videos are analysed, never
redistributed. Shippable assets require a licence ledger row. See
`docs/LICENSING.md`.
