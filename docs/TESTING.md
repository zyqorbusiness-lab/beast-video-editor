# Testing and verification status

Honest record of what is verified in this repo, and what is not.
Nothing below is claimed beyond the check listed.

## Verified (run locally, Nov 19 2026)

- **Test suite**: `node tests/run-tests.mjs` - 41 checks, all passing
  (count from the actual run output). Covers: tool scripts present, all
  10 skills present with frontmatter, demo beat-sheet timing rules (12f
  word gaps, 2-4f flash, >=60f end-card hold, no wall-clock reads),
  python tools compile, no video/audio binaries in the tree, plus the
  2026-11-19 additions below. (Earlier revisions of this file said 24;
  the first CI run reported 32 - the current suite is 41.)
- **Native-fps extraction** (new): `extract_reference.sh` defaults to the
  source's native fps and writes `extraction_fps.txt`. Dogfooded on all
  five reference reels; extracted PNG counts match `ffprobe` nb_frames
  exactly: metros 329 @30, barsol 803 @30, edworld 1380 @60,
  yunsan 1073 @60, adito 659 @24. The old 30fps-default sampling (dropped
  60fps detail, duplicated 24fps frames) is gone. Silent videos skip the
  audio WAV with a note instead of failing. Suite runs a 24fps synthetic
  clip through extract -> audio_events -> encode -> qa_sheets ->
  side_by_side as an end-to-end smoke test.
- **Frame labels**: burned labels (e.g. `F00150 | 00:00:04.967`) visually
  confirmed on extracted frames in the original dogfood.
- **audio_events.py**: re-run on all five reference tracks at native fps;
  onset counts and rough BPM estimates are cited in
  `docs/reference-analysis/00-overview.md` (BPM labelled estimate; the
  autocorrelation search window is now fps-independent after a 60fps run
  produced a nonsense ~277 BPM figure).
- **Reference viewing**: per-reel sheet counts and viewing status in
  `docs/reference-analysis/00-overview.md` - all five reels fully
  re-viewed at native cadence on 2026-11-19 (adito 11 sheets, yunsan 18,
  edworld 23); metros/barsol unchanged (native = 30fps).
  Measured corrections from the 2026-11-19 pass: yunsan wrapper window is
  95.5-95.7% of frame width (was "80-85%"), yunsan end card holds 74
  frames = 1.23s fully formed (was "well over 3s"), adito typewriter runs
  ~1-1.6 chars/frame (was "~3-4 per 10"), adito cascade lands ~1
  card/frame (was "2-3"), adito end card 54 frames = 2.25s.
- **preflight.sh asset-ledger enforcement** (new): fails when a shippable
  file in `assets/` lacks a row in `assets/ledger.md`; `ref_audio.wav`
  and `mixed_audio.wav` exempt. Three suite tests cover fail/pass/exempt.
- **Pinterest inspiration pass**: live signed-in session 2026-11-19, three
  searches + one pin detail view; 10 references with borrow notes recorded
  in `docs/inspiration-board.md` (URLs + notes only, no images).

- **motion_measure.py**: dogfooded on the yunsan reference (subscribe-bar
  exit). It measured a 4-frame, 118.7px move at absolute frames 369-372
  (30fps sample) with closest easing fit ease_out_back (RMSE 0.078); the
  measured segment was visually confirmed against the actual frames. Known
  limitation found by the same dogfood: a template whose appearance
  changes mid-move (the button's SUBSCRIBE -> SUBSCRIBED state flip)
  breaks tracking, so the entrance was not captured. Stated in the skill,
  not hidden.
- **side_by_side.sh**: dogfooded as a determinism proof on both demos:
  two independent renders compared frame-by-frame - kinetic-demo 240/240
  pairs and promo-demo 390/390 pairs pixel-identical (mean_abs_diff
  0.000). The documented `[tile WxH]` argument is now implemented.
- **Demo render**: `examples/kinetic-demo` rendered to
  `out/kinetic-demo.mp4` (ffprobe: 1080x1920, 30fps, 240 frames, 8.0s).
  Six frames (14, 40, 91, 105, 130, 200) were extracted into a 3x2 tile
  and visually inspected: word pop states correct, no overlap, white flash
  fully covers the cut frame, end card correct. A first render had a
  word-overlap and a flash z-order bug; both were fixed and re-verified.
- **promo-demo**: rendered 1080x1920 30fps 390 frames + AAC audio. Six key
  frames visually inspected across two QA rounds (first render had
  overlapping hook words and a scene-boundary bug; both fixed and
  re-verified). Audio sync verified: synthesized impacts at 5.000s/11.000s
  detected by tools/audio_events.py at 5.033s/11.033s (within the +/-1
  frame rule); BPM estimate 120.0 vs true 120.
- **Export settings consistency**: `tools/encode.sh`, the brief, and
  `skills/deterministic-render/SKILL.md` all specify crf 16 (the skill
  previously said 18 - fixed).

## CI

- Workflow: `.github/workflows/test.yml` runs the 41-check suite plus a
  real demo render smoke test (ffmpeg + chromium render + ffprobe).
- Run 44499109024 on commit d0772c5: every step green
  (https://github.com/zyqorbusiness-lab/beast-video-editor/actions/runs/44499109024).
  That run's summary showed Node 20 deprecation annotations from
  `actions/checkout@v4` / `actions/setup-node@v4`; the workflow now uses
  `actions/checkout@v7` / `actions/setup-node@v7` (current supported
  majors as of 2026-11-19). The run on the commit carrying this note is
  the first with the updated actions - see the repo's Actions tab.
- Step-level status above is from the GitHub API job listing; raw
  per-command log lines were not pulled line-by-line for this record.
- Run 44506077519 on the final tree: RED on a clean runner - the suite's
  audio pipeline step aborted (numpy missing) and the two preflight-pass
  checks failed (preflight's python module check found numpy/PIL absent).
  Local runs passed because the dev environment already had these
  installed; the workflow installed ffmpeg but no python packages. Fix:
  `requirements.txt` (numpy, pillow, scipy) added at repo root, a
  setup-python + `pip install -r requirements.txt` step added to the
  workflow, and scipy added to preflight's module check to match
  tools/motion_measure.py's actual imports. Diagnosis is from the source
  and job step listing; the raw failing log needs repo admin rights to
  download anonymously, so per-line failure text is not quoted here.

## Not yet verified

- **Remotion route** (skills/deterministic-render Route B): documented,
  not implemented in an example.
- **Full-reel recreation**: no recreation of a reference reel has been
  rendered with this toolkit yet. promo-demo proves the full toolchain
  (colour + type + motion + audio + encode + QA) on original content.
- **Full audio deconstruction** (brief Step 2 beyond onsets): genre/mood,
  builds/drops, per-SFX frame/trigger, word-level voice timing and
  mix/ducking/fades are not automated and were not done for the five
  studied reels.
