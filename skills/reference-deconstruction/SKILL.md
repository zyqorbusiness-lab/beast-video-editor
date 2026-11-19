---
name: reference-deconstruction
description: Break any reference video into frame-accurate, measurable facts (cuts, holds, type timing, transitions, audio sync) before recreating its techniques. Use at the start of every edit that has a reference.
---

# Reference deconstruction

Never recreate from vibes. Measure first, then build.

## Pipeline

1. **Probe**: `ffprobe` the reference for resolution, fps, duration, codec.
2. **Extract labeled frames**: `tools/extract_reference.sh <video> <outdir>`
   extracts EVERY frame at the native fps by default (never skip a frame;
   pass an explicit fps only for a deliberate, labelled sample) and burns
   `F00001 | 00:00:00.033` onto every frame so every observation is
   citable by frame number.
3. **Contact sheets**: the same script tiles the labeled frames into 10x6
   sheets in `<outdir>/contact_sheets/`. View every sheet. Skipping sheets
   is how mid-reel techniques get missed (barsol's colour-block punch is
   in one 2-second window). After a recreation render exists,
   `tools/qa_sheets.sh <rendered.mp4> <outdir>` builds the side-by-side
   [reference | recreation] QA sheets.
4. **Audio events**: `tools/audio_events.py <audio.wav>` produces onset
   times and a rough BPM estimate. Mark the estimate as rough.
5. **Measure motion**: `tools/motion_measure.py <frames> --template
   X,Y,W,H --template-frame N` tracks an element across frames and reports
   move segments (start/peak/settle frames, travel px) with a best-fit
   easing among standard families + RMSE. Cite it as "closest fit", never
   an exact bezier recovery. Known limit: if the element changes appearance
   mid-move (state flip, morph), tracking breaks - re-anchor the template
   after the change.
6. **Write the study**: techniques with frame numbers, numbers worth
   stealing, and which skill should encode each lesson. See
   `docs/reference-analysis/` for five worked examples.

## What to measure

- Cut points (frame numbers) and cut periods (frames between cuts)
- Text: words per phrase, frames per word, pop/settle durations
- Transitions: type, length in frames, position (cut vs mid-shot)
- Holds: end card length, logo holds, pause beats
- Colour: brand accent, system accent, where each is spent
- Audio sync: which visual events land on onsets

## Rules

- Analysis output is words and numbers only. Never commit reference frames
  or audio. Attribution = creator handle + reel URL.
- "Recreated the reference exactly" is a false claim. Say which techniques
  were reproduced and how they were verified.
