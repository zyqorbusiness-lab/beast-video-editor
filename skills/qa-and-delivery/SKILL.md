---
name: qa-and-delivery
description: Verify an edit before delivery - contact-sheet QA, side-by-side reference comparison, self-healing fix loop, and honest delivery notes. Use on every render before it ships.
---

# QA and delivery

## QA loop

1. Render (deterministic-render).
2. `tools/qa_sheets.sh` on the output - view every sheet. Look for:
   text clipping, off-grid alignment, dead frames, wrong accent usage,
   missed caption words.
3. Side-by-side: `tools/side_by_side.sh <ref_frames> <render_frames>
   <out_dir>` builds paired [ref|render] 5x6 sheets plus a numeric
   mean-abs-diff per pair. The numeric diff proves determinism on
   re-renders (expect 0.000); for recreation QA it is a smoke signal only -
   technique comparison against the study's "numbers worth stealing" stays
   a human check, never a pixel-match claim.
4. Fix and re-render. Each loop changes one class of thing (timing OR
   colour OR layout), so regressions are attributable.

## Honest verification language

- Say "verified by viewing N contact sheets" only if the sheets were
  actually viewed.
- Say "technique reproduced" with the frame numbers checked, never
  "recreated the reference".
- Unverified steps are listed as unverified in delivery notes. See
  `docs/TESTING.md` for this repo's own example.

## Delivery checklist

- [ ] Preflight passed (`tools/preflight.sh`)
- [ ] QA sheets viewed, issues fixed or declared
- [ ] Asset ledger complete (asset-sourcing)
- [ ] Export settings per deterministic-render
- [ ] Delivery note: what was verified, what was not, known limitations
