# promo-demo

An original 13s end-to-end promo exercising the toolkit's colour, motion,
type, and audio-sync skills together. No reference footage, no external
assets: the audio bed is synthesized by `make_audio.py` (licence-free by
construction) and every visual is code.

## What it demonstrates

- **Colour system** (skills/colour-theory): bg `#0A0A0C`, brand accent
  `#FF7A1A`, system accent `#3DD68C` spent only on the active word.
- **Word-by-word type** (skills/kinetic-typography): hook words land on
  kick beats (f0, f15, f30 at 120 BPM), 4f pop + 3f settle.
- **Motion graphics** (skills/motion-graphics): 3f white flash + impact on
  the scene change (f150), spotlight mask reveal (f150-159), card cascade
  with 3f stagger (PLAN/BUILD/SHIP, f160-168), end-card colour block with
  60f hold (f330+).
- **Audio sync** (skills/audio-sync): the synthesized track has impacts at
  exactly 5.000s and 11.000s; `tools/audio_events.py` detects them at
  5.033s and 11.033s (within the +/-1 frame rule), and estimates
  120.0 BPM against the true 120 BPM.

## Run

```bash
npm install
python3 make_audio.py   # writes assets/mixed_audio.wav
npm run render          # frames + mux -> out/promo-demo.mp4
```

Requires Chrome/Chromium (`CHROME_PATH`), ffmpeg, python3+numpy.

## Verification (see docs/TESTING.md)

Rendered 1080x1920 30fps 390 frames + AAC. Six key frames visually
inspected (two QA rounds: first render had overlapping hook words and a
scene-boundary bug, both fixed and re-verified). Two independent renders
compared with tools/side_by_side.sh: 390/390 pairs pixel-identical
(mean_abs_diff 0.000), proving determinism.

## Honest scope

This is an original skills demo, not a recreation of any reference and not
a finished commercial promo. Audio is a synthesized click/impact bed, not
a mixed music track.
