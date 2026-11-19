#!/usr/bin/env python3
"""audio_events.py - programmatic onset/transient detection + rough BPM.

Reads <workspace>/assets/ref_audio.wav (44.1 kHz PCM, from extract_reference.sh)
and writes <workspace>/audio_events.json:

  {"fps": 30, "bpm_estimate": 128.0,
   "transient_peaks": [{"frame": 17, "time_sec": 0.567, "rms": 812.4}, ...]}

Frame numbers are 1-based positions on the study-fps timeline, so a peak at
frame 17 means "something audible hits inside frame F00017". A human still has
to listen and label WHAT each peak is (beat, whoosh, pop, voice) - this script
only says WHERE the energy is.
"""
import json
import sys
import wave

import numpy as np


def main() -> None:
    workspace = sys.argv[1] if len(sys.argv) > 1 else "./recreate_workspace"
    fps = int(sys.argv[2]) if len(sys.argv) > 2 else 30
    if workspace.lower().endswith(".wav"):
        # direct WAV path: events json lands next to it, fps from arg 2
        wav_path = workspace
        out_path = wav_path.rsplit(".", 1)[0] + "_events.json"
    else:
        wav_path = f"{workspace}/assets/ref_audio.wav"
        out_path = f"{workspace}/audio_events.json"

    with wave.open(wav_path, "rb") as wf:
        sr, ch = wf.getframerate(), wf.getnchannels()
        raw = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16).astype(np.float32)
    if ch > 1:
        raw = raw.reshape(-1, ch).mean(axis=1)

    hop = sr // fps
    energy = np.array(
        [np.sqrt(np.mean(raw[i : i + hop] ** 2)) for i in range(0, len(raw) - hop, hop)]
    )
    if len(energy) < 3:
        raise SystemExit("audio too short for onset detection")

    threshold = energy.mean() + 1.35 * energy.std()
    peaks = [
        {"frame": i + 1, "time_sec": round((i + 1) / fps, 3), "rms": round(float(energy[i]), 1)}
        for i in range(1, len(energy) - 1)
        if energy[i] > threshold and energy[i] > energy[i - 1] and energy[i] >= energy[i + 1]
    ]

    # Rough BPM from onset autocorrelation (search 2..0.5 beat/sec window).
    onsets = np.maximum(np.diff(energy), 0)
    ac = np.correlate(onsets, onsets, "full")[len(onsets) - 1 :]
    lo, hi = 8, min(60, len(ac) - 1)
    bpm = None
    if hi > lo and ac[lo:hi].size:
        lag = int(np.argmax(ac[lo:hi]) + lo)
        bpm = round(60 * fps / lag, 1)

    with open(out_path, "w") as fh:
        json.dump({"fps": fps, "bpm_estimate": bpm, "transient_peaks": peaks}, fh, indent=2)
    print(f"{len(peaks)} peaks, ~{bpm} BPM -> {out_path}")


if __name__ == "__main__":
    main()
