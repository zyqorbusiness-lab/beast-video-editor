---
name: motion-graphics
description: Reusable motion-graphics patterns observed in top reels - branded wrappers, overlays, UI-typing animations, card cascades, and 2.5D fakes for 3D looks. Use when an edit needs graphic moments beyond captions.
---

# Motion graphics patterns

Ground truth: `docs/reference-analysis/02` (barsol), `04` (yunsan),
`05` (adito).

## Branded wrapper (showreel packaging)

Background (brand pattern) + rounded video window (~80-85% frame width,
consistent corner radius) + header sticker + progress element + end card.
The wrapper never changes mid-reel. See yunsan study.

## Overlay library (talking-head)

- **Context map**: dotted world map with pins, full width, under subject.
- **B&W photo cards**: desaturated photo + accent-colour numbers/labels.
- **Colour-block punch**: full-screen brand-accent block with one huge word
  (~1.5s minimum hold).
- **Masked pop-out**: subject cut-out over a graphic (arrow, burst).

## UI-typing animation

Frosted-glass card + animated cursor; type at ~3-4 chars per 10 frames
@24fps with a blinking caret; results stagger in 2-3 frames apart. Fake the
glass with: semi-transparent white panel, background blur, 1px light border.

## Card cascade

Duplicate a card into a curved array; each lands 2-3 frames after the
previous with slight rotation/scale decay. Cap at ~10 visible cards.

## 2.5D instead of 3D

On a free CPU-only toolchain, fake the adito look: layered PNGs with
parallax (background moves less than foreground), scale+blur for depth,
soft shadows. State plainly in delivery notes that it is 2.5D, not 3D.
