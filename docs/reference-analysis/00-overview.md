# Reference Study: Overview

Five reels from the owner's edit-reference-kit (release v1.0) were deconstructed
as the ground truth for this toolkit's skills. Every claim in the per-reel
files comes from viewing labeled frame extractions assembled into contact
sheets, plus an audio onset analysis (`tools/audio_events.py`).

**Extraction rule (fixed 2026-11-19):** frames are extracted at each reel's
NATIVE fps, so no source frame is skipped or duplicated. An earlier pass
sampled everything at 30fps, which dropped motion detail from the two 60fps
reels and duplicated frames on the 24fps reel; the affected reels were
re-extracted and re-studied on 2026-11-19 with the counts below.

| Study | Creator | Reel | Format | Duration | Frames (native) | Sheets | Audio onsets | BPM (rough est.) |
|---|---|---|---|---|---|---|---|---|
| metros | @metros.creative | https://www.instagram.com/metros.creative/reel/DfFo9D0IZM0/ | 1080x1920 @ 30fps (native) | 10.97s | 329 | 6 | 11 | ~60.0 |
| barsol | @barsolmedia | https://www.instagram.com/barsolmedia/reel/Dd1Mf7xzsbm/ | 1080x1920 @ 30fps (native) | 26.77s | 803 | 14 | 41 | ~62.1 |
| edworld | @editingworld8755 | https://www.instagram.com/editingworld8755/reel/DZgzUHxSLBG/ | 1080x1920 @ 60fps (native) | 23.00s | 1380 | 23 | 63 | ~83.7 |
| yunsan | @yunsan_studio | https://www.instagram.com/yunsan_studio/reel/DfSwqnwTlCg/ | 1080x1920 @ 60fps (native) | 17.88s | 1073 | 18 | 52 | ~150.0 |
| adito | @madebyadito | https://www.instagram.com/madebyadito/reel/DejPNbqtu4_/ | 1920x1080 @ 24fps (native) | 27.46s | 659 | 11 | 37 | ~46.5 |

Frame counts are the extracted PNG counts from `tools/extract_reference.sh`
and matched each file's `ffprobe` nb_frames exactly when measured 2026-11-19.

**Provenance (honest):** the counts, sheet views and measured observations in
this directory are Instinct-reported. The source reels, extracted frames and
contact sheets are NOT in this repo (licensing posture, see `docs/LICENSING.md`),
so these numbers cannot be independently reproduced from the public repo
alone - they record what was measured during the 2026-11-19 build session.
Onset counts and BPM come from `tools/audio_events.py` run on each reel's
audio at its native fps; BPM is a rough onset-density estimate, not a
beat-tracked value.

## Viewing status (honest, per reel; Instinct-reported)

- **metros** - all 6 sheets viewed (30fps study; unchanged, native = 30fps).
- **barsol** - all 14 sheets viewed (30fps study; unchanged, native = 30fps).
- **adito** - all 11 sheets re-viewed at native 24fps on 2026-11-19. Numbers
  in the study marked "measured" come from this pass.
- **yunsan** - re-extracted at native 60fps; all 18 sheets re-viewed at
  native cadence on 2026-11-19. Numbers in the study marked "measured"
  come from this pass.
- **edworld** - re-extracted at native 60fps; all 23 sheets re-viewed at
  native cadence on 2026-11-19. Scene inventory confirmed against the
  native-cadence sheets.

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
- **A held end card.** Every reel ends with a branded card (logo, socials,
  or "REACH US"). Measured holds are in the per-reel studies.
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
