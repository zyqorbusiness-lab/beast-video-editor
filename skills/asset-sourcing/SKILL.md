---
name: asset-sourcing
description: Source music, SFX, fonts, images and inspiration boards legally and free - Pinterest-first for references, licensed-only for anything that ships. Use whenever an edit needs an external asset.
---

# Asset sourcing

## Two categories, two rulesets

**Inspiration/reference** (Pinterest boards, other creators' reels): study
freely, never ship. The owner's Pinterest (@zyqorbusiness) is the first
stop for look references - build a board per project, then close it.
Reference frames never enter the deliverable or the repo.

**Shippable assets** (music, SFX, fonts, stock): only sources with a
licence that permits the intended use, recorded at pickup time.

## Approved free sources

- Music/SFX: YouTube Audio Library, Pixabay, Freesound (check per-asset
  licence), myinstants (meme SFX - verify clip licence before shipping).
- Fonts: Google Fonts (OFL). Record the family and licence URL.
- Images/video: Pexels, Pixabay, Unsplash, Mixkit, Wikimedia Commons
  (check their licence terms).
- Icons/UI vectors: Iconify API, Lucide, Heroicons (MIT/ISC - still record
  the row).
- Real-world assets (hands, cursors, products, textures): source real
  photos/cutouts, never fake them with CSS shapes; remove backgrounds
  offline (rembg/Pillow) when a clean cutout is needed.

## Asset ledger (required)

Every shippable asset gets a ledger row in the project:

| Asset | Source URL | Licence | Downloaded | Used at |
|---|---|---|---|---|

No ledger row, no render. `tools/preflight.sh` fails a build whose
ledger is missing entries for files in `assets/`.

## Red flags (do not ship)

- "Free download" sites with no stated licence
- Watermarked previews (any envato/pond5 preview)
- Popular songs - a reel with chart music is a takedown, not a flex
