---
name: reference-deconstruction
description: Break any reference video into frame-accurate, measurable facts (cuts, holds, type timing, transitions, audio sync) before recreating its techniques. Use at the start of every edit that has a reference.
---

# Reference deconstruction

Never recreate from vibes. Measure first, then build.

## Pipeline

1. **Probe**: `ffprobe` the reference for resolution, fps, duration, codec.
   Note when fps is below 30 (30fps extraction duplicates frames) or above
   (30fps sampling drops motion detail) - say which you did.
2. **Extract labeled frames**: `tools/extract_reference.sh <video> <outdir>`
   burns `F00001 | 00:00:00.033` onto every frame so every observation is
   citable by frame number.
3. **Contact sheets**: `tools/qa_sheets.sh <frames_dir>` builds 10x6 sheets.
   View every sheet. Skipping sheets is how mid-reel techniques get missed
   (barsol's colour-block punch is in one 2-second window).
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
