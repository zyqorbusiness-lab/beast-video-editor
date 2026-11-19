---
name: captions
description: Word-by-word animated captions for talking-head and voiceover clips - timing, emphasis words, pop animation, and placement. Use on any speech-driven footage.
---

# Captions

Ground truth: `docs/reference-analysis/02-barsol-podcast-captions.md`.

## Timing source

Word timings come from a transcript with word-level timestamps (any local
whisper build gives these). Never estimate by ear for the final pass; the
ear pass is for choosing emphasis, not timing.

## The pop

- One word visible at a time (or the current phrase chunk of 2-4 words).
- Entrance: scale 1.0 -> ~1.15 over ~4 frames @30fps, settle ~3 frames.
- Active word is the largest, brightest element on screen during speech.

## Emphasis words

- Pick 1-3 per sentence maximum: the words that carry the point.
- Style: accent colour + italic serif (or weight jump), held for exactly
  the spoken duration of the word, then back to base style.
- Hinglish/multilingual: emphasis works on romanised Hindi words the same
  way. Keep one base font that covers all scripts used; do not mix fonts
  mid-sentence.

## Placement

- Lower third, clear of platform UI (bottom ~25% is covered by reel
  controls; keep captions in the 55-75% height band).
- Never cover the speaker's mouth - captions under the chin line.

## Discipline

- Transitions happen on cuts, not on captions.
- No glow on captions unless the accent system already uses glow
  elsewhere; selective glow only.
