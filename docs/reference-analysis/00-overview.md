# Reference Study: Overview

Five reels from the owner's edit-reference-kit (release v1.0) were deconstructed
frame-by-frame as the ground truth for this toolkit's skills. Every claim in the
per-reel files comes from viewing labeled frame extractions (every frame at the
reel's native cadence, frame number + timestamp burned in) assembled into
contact sheets, plus an audio onset analysis (`tools/audio_events.py`).

| Study | Creator | Reel | Format | Duration | Frames studied | Audio peaks |
|---|---|---|---|---|---|---|
| metros | @metros.creative | https://www.instagram.com/metros.creative/reel/DfFo9D0IZM0/ | 1080x1920 @ 30fps | 10.97s | 329 | 11 onsets (~40 BPM est.) |
| barsol | @barsolmedia | https://www.instagram.com/barsolmedia/reel/Dd1Mf7xzsbm/ | 1080x1920 @ 30fps | 26.77s | 803 | (onset map on file) |
| edworld | @editingworld8755 | https://www.instagram.com/editingworld8755/reel/DZgzUHxSLBG/ | 1080x1920 @ 60fps | 23.00s | 690 (30fps sample) | 40 onsets (~200 BPM est.) |
| yunsan | @yunsan_studio | https://www.instagram.com/yunsan_studio/reel/DfSwqnwTlCg/ | 1080x1920 @ 60fps | 17.88s | 537 (30fps sample) | 30 onsets (~112.5 BPM est.) |
| adito | @madebyadito | https://www.instagram.com/madebyadito/reel/DejPNbqtu4_/ | 1920x1080 @ 24fps | 27.46s | 824 (30fps sample, duplicates) | 47 onsets (~36.7 BPM est.) |

The BPM figures are rough onset-density estimates, not beat-tracked values.

## Why these five

They cover five distinct craft families this toolkit must teach:

1. **metros** - pure kinetic typography (no footage dependence)
2. **barsol** - talking-head podcast captions + graphic overlays
3. **edworld** - before/after showcase (raw vs graded/edited comparison)
4. **yunsan** - branded showreel wrapper (frame-within-frame packaging)
5. **adito** - 3D motion-graphics product ad (landscape, UI animation)

## Cross-reel patterns (what the best reels share)

- **Word-by-word text.** Captions and titles land one word (or one phrase
  chunk) at a time, timed to speech or to music. Four of five reels do this.
- **One accent colour, repeated.** barsol: red. edworld: orange/green.
  yunsan: pink. adito: purple. metros: white + warm flame tones. Each reel
  picks one accent and spends it only on emphasis words and key graphics.
- **Flash transitions on cuts.** White/colour flashes and light sweeps happen
  at scene changes, never mid-shot and never on text entrances.
- **A held end card.** Every reel ends with a static branded card held 2-3s+
  (logo, socials, or "REACH US"). The hold is part of the craft.
- **Masked subject pop-outs.** edworld and barsol both cut the subject out of
  the frame and layer it over graphics - the single most recurring
  "premium" move in talking-head work.
- **Progress/timeline graphics.** yunsan runs a fake editor-timeline progress
  bar at the bottom of the frame; it reads as craftsmanship proof.

## Licensing note

Reference footage and audio were analysed only. No reference frame, frame
crop, or audio is committed to this repository. Analysis files contain words
and numbers only; attribution is creator handle + reel URL, as above.
See `docs/LICENSING.md`.
