---
name: audio-sync
description: Align cuts, text entrances and transitions to audio events using onset detection and a rough BPM estimate. Use after the rough cut, before final polish.
---

# Audio sync

Tool: `tools/audio_events.py <audio.wav>` -> onset times + rough BPM.

## Method

1. Extract audio: `ffmpeg -i input.mp4 -vn -ac 1 -ar 22050 audio.wav`.
2. Run onset detection. Output: onset times (seconds) and a BPM estimate.
   The BPM figure is onset-density based - treat it as a vibe check, not a
   beat grid, and label it "estimate" in any doc.
3. Snap visual events to onsets:
   - Cut points: nearest onset within +/-3 frames; if none within 3, the
     cut was probably wrong - recheck.
   - Text entrances: snap word pops to onsets when the word is spoken on
     one; otherwise keep transcript timing.
   - Transitions: the flash/wipe peak lands exactly on the onset.
4. SFX: one per transition maximum. Whoosh on wipes, impact on flashes.
   Licensed sources only (see `skills/asset-sourcing/SKILL.md`).

## Density sanity check

Compare your event density to the reference class: ~46 BPM (slow, adito)
to ~150 BPM (dense, yunsan) both work - but a mid-energy track with sparse
cuts feels asleep, and a dense track with slow cuts feels dragged. Match
density to the track. (All BPM figures are rough onset-density estimates.)
