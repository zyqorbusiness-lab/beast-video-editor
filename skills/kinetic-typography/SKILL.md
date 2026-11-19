---
name: kinetic-typography
description: Build word-by-word kinetic type sequences with measured timing, two-family type pairing, and frame-exact entrance animations. Use for title sequences, lyric/quote reels, and text-led hooks.
---

# Kinetic typography

Ground truth: `docs/reference-analysis/01-metros-kinetic-typography.md`.

## Type system

Two families maximum:
- **Emotional/display** - serif or script; carries the feeling word.
- **Information** - heavy sans; carries the fact word.

Mixing them within one phrase creates hierarchy for free. A third family
reads as a mistake.

## Timing rules (frames, at 30fps)

- Word entrance: 3-5 frames scale-up (1.0 -> ~1.1) with 2-3 frame settle.
- Minimum word hold: 12 frames before the next word lands.
- Phrase gap: 6-10 frames between phrases.
- A/B cut alternation for energy: ~15 frames per framing.
- End card: hold 60-90 frames (2-3s).

## Text-behind-subject

Layer order: background -> text -> masked subject. The subject cut-out sits
above the text so words pass behind it. Get the mask from a still frame
(remove.bg-style offline tools, or a rotobrush pass in any editor) and keep
it static unless the subject moves significantly.

## No-AI-feel checklist

- Easing is explicit (e.g. cubic-bezier(0.22, 1, 0.36, 1)), never "smooth".
- Every entrance is 3-5 frames, not 0 - instant pops read as template.
- Kerning/wrapping checked per word; no automated full-sentence dumps.
- Numbers in frames, not seconds-fractions like "0.33s".
