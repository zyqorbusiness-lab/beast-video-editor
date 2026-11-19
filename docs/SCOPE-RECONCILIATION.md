# Scope reconciliation: brief vs this repo

Item-by-item status of the owner's brief (the supplied PDF) against what
this repo implements today. Statuses: DONE (implemented and verified),
PARTIAL (implemented at toolkit level, not exhaustively), DOCUMENTED
(workflow written, not executed in an example), GAP (not implemented).

| Brief item | Where in repo | Status |
|---|---|---|
| Step 0 environment preflight (ffmpeg/python/node checks) | tools/preflight.sh | DONE (dogfooded) |
| Step 1 metadata + full frame extraction + labeled frames + 10x6 contact sheets + audio WAV | tools/extract_reference.sh, tools/qa_sheets.sh | DONE (native-fps extraction is the default since 2026-11-19 - no skipped/duplicated frames; all 5 reels re-extracted with counts matching ffprobe; labels verified on frames) |
| Step 2 audio analysis (RMS onsets + BPM estimate) | tools/audio_events.py | PARTIAL: programmatic RMS onset peaks + rough BPM estimate are done and re-run at native fps on all 5 reels. The brief's full audio log - genre/mood, builds/drops/hits labelled by type, per-SFX frame + trigger, word-level voice timing, mix/levels/ducking/fades - is NOT done: it needs listening and human labelling, and is not automated here |
| Step 3/3B visual + motion + text deconstruction with exact numbers | skills/reference-deconstruction + docs/reference-analysis/* | PARTIAL: cut periods, holds, staggers, flash lengths measured; per-property bezier/spring extraction for every element is manual guidance, not automated |
| Step 3C asset inventory + ledger enforcement | skills/asset-sourcing (ledger), tools/preflight.sh | DONE: preflight.sh fails when a shippable file in assets/ has no row in assets/ledger.md (tested in the suite); ref_audio.wav / mixed_audio.wav exempt by design |
| Step 4 gapless timeline | skills/edit-planning + docs/templates/timeline.md | DONE (template + rule) |
| Step 5 style breakdown (pacing, animation language, sync rules) | docs/reference-analysis/* per-reel sections | DONE for the 5 studied reels |
| Step 6 mistakes/drift audit + improvements | skills/qa-and-delivery + tools/side_by_side.sh (numeric mean-abs-diff drift) | DONE (drift dogfooded as determinism proof) |
| Step 6B Pinterest inspiration board | docs/inspiration-board.md | DONE (live pass 2026-11-19, 10 references with borrow notes; URLs + notes only, no images) |
| Step 7 asset sourcing priority (Pinterest/Google real assets, Iconify/Lucide, Pexels/Pixabay/Mixkit/Wikimedia, own recordings, licensed audio) | skills/asset-sourcing | DOCUMENTED (approved-source list + ledger rule + red flags) |
| Step 8 hybrid build (Engine A Playwright / Engine B Remotion) | skills/deterministic-render; examples/kinetic-demo (Engine A) | Engine A DONE + verified; Engine B DOCUMENTED only |
| window.seekToFrame harness | examples/kinetic-demo/render.mjs + composition.html (window.__frame clock, equivalent contract) | DONE |
| Step 9 deterministic render + encode (crf 16, aac 192k, faststart) | render.mjs + tools/encode.sh | DONE (encode.sh matches spec incl. optional 2x-fps tmix motion-blur pass) |
| Motion blur via 2x-fps render + pair blending | tools/encode.sh BLEND=1 | DONE in tool; NOT exercised in the demo (demo has no fast lateral motion to blur) |
| Step 10 side-by-side [ref\|recreation] QA + self-healing loop | tools/side_by_side.sh (paired hstack sheets + numeric drift) | DONE (tool built and dogfooded; no recreation shipped yet to point it at) |
| Output: final video + matched/improved note | docs/TESTING.md pattern (verified/unverified lists) | DONE as process; no end-to-end recreation shipped yet |

| End-to-end original build exercising all skills together | examples/promo-demo | DONE (rendered + verified; original content only) |

## Known gaps (next milestones)

1. Remotion example (Engine B) - documented, not implemented.
2. A full recreation of one reference reel with its own timeline.md,
   proving the loop on real footage (tools ready, not yet executed).
3. motion_measure.py: template appearance changes mid-move break tracking
   (found in dogfood); a multi-template mode is the follow-up.
4. Easing fit is best-match among standard families with RMSE, by design;
   exact cubic-bezier recovery stays a human step.
5. Full audio deconstruction per the brief (Step 2 details above) -
   onsets are automated, the rest is a listening pass that has not been
   done for the 5 studied reels.
6. yunsan and edworld were re-extracted at native 60fps; not every
   regenerated contact sheet has been re-viewed yet (per-reel viewing
   status: docs/reference-analysis/00-overview.md).
