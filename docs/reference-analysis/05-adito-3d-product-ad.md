# Study: madebyadito - 3D motion-graphics product ad

- Reel: https://www.instagram.com/madebyadito/reel/DejPNbqtu4_/
- 1920x1080 @ 24fps (native), 27.46s, 659 frames extracted at native
  cadence (11 contact sheets), zero duplicated frames. Originally studied
  from an 824-frame 30fps sample in which ~1 in 5 frames was a duplicate;
  re-extracted at 24fps and all 11 sheets re-viewed on 2026-11-19.
  Numbers marked "measured" come from the native-cadence pass.
- Audio: 37 onsets, ~46.5 BPM estimate (rough onset-density estimate)

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

- Typewriter cadence: measured at native 24fps - about 1-1.6 characters
  per frame (the 30-character search query "best quality budget
  headphones" completes in ~19 frames, frames ~356-374; the "It's
  Deciding" and "What if I told You" typings run at the same ~1
  char/frame pace). The earlier "~3-4 characters per 10 frames" figure
  was roughly 4x too slow.
- Card cascade stagger: cards land about one per frame across frames
  ~102-110 (counted on the native contact sheet). The earlier "2-3
  frames" estimate was too slow.
- End card hold: the white "Bundance" card holds frames 606-659 = 54
  frames = 2.25s at 24fps (measured).
- Gradient type: one word per ~0.5-0.8s on slow scores (estimate)

## What this teaches the toolkit

`skills/motion-graphics/SKILL.md` covers the UI-typing and card-cascade
patterns; `skills/deterministic-render/SKILL.md` uses this reel to argue
why 3D-look moments should be faked with 2.5D layering (parallax, scale,
blur) when the toolchain must stay free and CPU-only.
