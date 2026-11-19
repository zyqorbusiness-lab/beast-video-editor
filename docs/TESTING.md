# Testing and verification status

Honest record of what is verified in this repo, and what is not.
Nothing below is claimed beyond the check listed.

## Verified (run locally, Nov 19 2026)

- **Test suite**: `node tests/run-tests.mjs` - 24 checks, all passing.
  Covers: tool scripts present, all 10 skills present with frontmatter,
  demo beat-sheet timing rules (12f word gaps, 2-4f flash, >=60f end-card
  hold, no wall-clock reads), audio_events.py compiles, no video/audio
  binaries in the tree.
- **Demo render**: `examples/kinetic-demo` rendered to
  `out/kinetic-demo.mp4` (ffprobe: 1080x1920, 30fps, 240 frames, 8.0s).
  Six frames (14, 40, 91, 105, 130, 200) were extracted into a 3x2 tile and
  visually inspected: word pop states correct, no overlap, white flash
  fully covers the cut frame, end card correct. A first render had a
  word-overlap and a flash z-order bug; both were fixed and re-verified.
- **extract_reference.sh**: dogfooded on all five reference reels; frame
  labels (e.g. `F00150 | 00:00:04.967`) visually confirmed on extracted
  frames. A drawtext escaping bug was found and fixed during this run.
- **audio_events.py**: run on all five reference tracks; onset counts and
  rough BPM estimates are cited in `docs/reference-analysis/00-overview.md`
  (BPM labelled as estimate).
- **Reference viewing**: all contact sheets for all five reels were viewed
  (metros 6, barsol 14, edworld 12, yunsan 9, adito 14). The studies in
  `docs/reference-analysis/` come only from those viewings.
- **Pinterest inspiration pass**: live signed-in session 2026-11-19, three
  searches + one pin detail view; 10 references with borrow notes recorded
  in `docs/inspiration-board.md` (URLs + notes only, no images).

- **motion_measure.py**: dogfooded on the yunsan reference (subscribe-bar
  exit). It measured a 4-frame, 118.7px move at absolute frames 369-372
  with closest easing fit ease_out_back (RMSE 0.078); the measured segment
  was visually confirmed against the actual frames. Known limitation found
  by the same dogfood: a template whose appearance changes mid-move (the
  button's SUBSCRIBE -> SUBSCRIBED state flip) breaks tracking, so the
  entrance was not captured. Stated in the skill, not hidden.
- **side_by_side.sh**: dogfooded as a determinism proof on both demos:
  two independent renders compared frame-by-frame - kinetic-demo 240/240
  pairs and promo-demo 390/390 pairs pixel-identical (mean_abs_diff 0.000).
- **promo-demo**: rendered 1080x1920 30fps 390 frames + AAC audio. Six key
  frames visually inspected across two QA rounds (first render had
  overlapping hook words and a scene-boundary bug; both fixed and
  re-verified). Audio sync verified: synthesized impacts at 5.000s/11.000s
  detected by tools/audio_events.py at 5.033s/11.033s (within the +/-1
  frame rule); BPM estimate 120.0 vs true 120.
- **audio_events.py usability fix**: now accepts a direct WAV path in
  addition to a workspace dir (found by dogfooding on promo-demo).

## Not yet verified

- **CI workflow**: `.github/workflows/test.yml` is written but has not run
  on GitHub yet. First push will be its first real run.
- **Remotion route** (skills/deterministic-render Route B): documented,
  not implemented in an example.
(nothing in this section now - see "Verified" above)
- **Full-reel recreation**: no recreation of a reference reel has been
  rendered with this toolkit yet. promo-demo proves the full toolchain
  (colour + type + motion + audio + encode + QA) on original content.
