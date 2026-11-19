# Study: madebyadito - 3D motion-graphics product ad

- Reel: https://www.instagram.com/madebyadito/reel/DejPNbqtu4_/
- 1920x1080 @ 24fps, 27.46s, 824 frames viewed at 30fps sampling
  (24fps source, so ~1 in 5 sampled frames is a duplicate - noted, not a
  problem for technique study) (14 sheets)
- Audio: 47 onsets, ~36.7 BPM estimate (slow, smooth score)

## What it is

A landscape 3D motion-graphics ad for a shopping product ("Bundance").
Pink/purple glassmorphic world. The only landscape piece in the study set,
which makes it the export-format contrast case.

## Techniques observed

- **3D scene with camera moves.** A pink desk diorama (monitor, lamp,
  plants) with slow dollies and orbits. Motion blur and depth of field sell
  the render quality.
- **Glassmorphic UI animation.** A frosted-glass search UI with an animated
  cursor types a query character by character ("best quality budget
  headphones|"), then results cascade in as 3D cards.
- **Cascading card arrays.** Product cards multiply into a curved 3D array
  with staggered timing - the classic "infinite options" visual.
- **Word-by-word typography on gradient.** "Shouldn't Feel Overwhelming"
  builds word by word over a soft pink gradient, with a letter-fill
  animation on the key word.
- **Typewriter text with accent words.** "What if I told You" types out;
  "You" flips to purple. "and Money" lands with inline emoji-style icons.
  "Get Smarter Deals" closes the loop on a purple gradient.
- **White-flash + match-cut transitions.** Bright white flashes bridge
  scene changes; the monitor screen acts as a match-cut portal between
  worlds (desk -> screen content -> new scene).
- **Logo hold end card.** Clean white card, logo centred, long hold.

## Numbers worth stealing

- Typewriter cadence: ~3-4 characters per 10 frames at 24fps
- Card cascade stagger: each card lands ~2-3 frames after the previous
- Gradient type: one word per ~0.5-0.8s on slow scores

## What this teaches the toolkit

`skills/motion-graphics/SKILL.md` covers the UI-typing and card-cascade
patterns; `skills/deterministic-render/SKILL.md` uses this reel to argue
why 3D-look moments should be faked with 2.5D layering (parallax, scale,
blur) when the toolchain must stay free and CPU-only.
