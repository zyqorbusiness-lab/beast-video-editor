#!/usr/bin/env python3
"""motion_measure.py - measure an element's motion from labeled frames.

Tracks a template (a crop of one frame containing the moving element)
across a frame sequence with FFT-normalized cross-correlation, then fits
the movement to common easing families. This MEASURES motion instead of
hand-logging it - per skills/reference-deconstruction.

It reports the best fit among standard easing families (linear, ease-out
cubic, ease-in-out cubic, ease-out quad, ease-out back/overshoot) with an
RMSE. It does not recover an exact cubic-bezier; say "closest match" in
write-ups, not "the easing is".

Usage:
  python3 motion_measure.py FRAMES_DIR --template X,Y,W,H --template-frame N \
      [--search RADIUS] [--downscale F] [--out motion.json]
Frames are any *.png in the dir, sorted by name.
"""
import argparse, json, glob, os, sys
import numpy as np
from PIL import Image
from scipy.signal import fftconvolve

def load_gray(path, ds):
    im = Image.open(path).convert("L")
    if ds > 1:
        im = im.resize((im.width // ds, im.height // ds), Image.BILINEAR)
    return np.asarray(im, dtype=np.float32)

def ncc_track(frames, tpl, start_xy, radius):
    """Yield (cx, cy, score) per frame, searching around the previous pos."""
    th, tw = tpl.shape
    tpl_z = tpl - tpl.mean()
    pos = start_xy  # (x, y) top-left of template in downscaled coords
    out = []
    for i, fr in enumerate(frames):
        x0 = max(0, pos[0] - radius); y0 = max(0, pos[1] - radius)
        x1 = min(fr.shape[1], pos[0] + tw + radius)
        y1 = min(fr.shape[0], pos[1] + th + radius)
        win = fr[y0:y1, x0:x1]
        if win.shape[0] < th or win.shape[1] < tw:
            out.append((pos[0] + tw / 2, pos[1] + th / 2, 0.0)); continue
        corr = fftconvolve(win, tpl_z[::-1, ::-1], mode="valid")
        denom = tpl_z.std() * tpl.size * win.std() + 1e-9
        score = corr / denom
        my, mx = np.unravel_index(np.argmax(score), score.shape)
        pos = (x0 + mx, y0 + my)
        out.append((pos[0] + tw / 2, pos[1] + th / 2, float(score.max())))
    return out

EASINGS = {
    "linear": lambda t: t,
    "ease_out_quad": lambda t: 1 - (1 - t) ** 2,
    "ease_out_cubic": lambda t: 1 - (1 - t) ** 3,
    "ease_in_out_cubic": lambda t: np.where(t < 0.5, 4 * t ** 3, 1 - (-2 * t + 2) ** 3 / 2),
    "ease_out_back": lambda t: 1 + 2.70158 * (t - 1) ** 3 + 1.70158 * (t - 1) ** 2,
}

def fit_easing(progress):
    t = np.linspace(0, 1, len(progress))
    best = None
    for name, fn in EASINGS.items():
        pred = fn(t)
        rmse = float(np.sqrt(np.mean((progress - pred) ** 2)))
        if best is None or rmse < best[1]:
            best = (name, rmse)
    return {"closest": best[0], "rmse": round(best[1], 4)}

def analyze(track, fps):
    d = np.array([[x, y] for x, y, s in track])
    disp = np.linalg.norm(np.diff(d, axis=0), axis=1)
    thr = max(1.5, disp.mean() + disp.std())
    segments, cur = [], None
    for i, v in enumerate(disp):
        if v > thr and cur is None:
            cur = {"start_frame": i + 1}
        elif v <= thr and cur is not None:
            cur["end_frame"] = i + 1; segments.append(cur); cur = None
    if cur is not None:
        cur["end_frame"] = len(disp) + 1; segments.append(cur)
    results = []
    for seg in segments:
        a, b = seg["start_frame"] - 1, min(seg["end_frame"], len(d) - 1)
        if b - a < 3:
            continue
        travel = np.linalg.norm(d[a:b + 1] - d[a], axis=1)
        if travel.max() < 2:
            continue
        progress = travel / travel.max()
        peak = int(np.argmax(travel)) + a + 1
        settle_tail = np.where(progress > 0.99)[0]
        settle = (int(settle_tail[0]) + a + 1) if len(settle_tail) else b + 1
        results.append({
            "start_frame": a + 1, "peak_frame": peak, "settle_frame": settle,
            "duration_frames": b - a + 1,
            "duration_sec": round((b - a + 1) / fps, 3),
            "travel_px": round(float(travel.max()), 1),
            "easing_fit": fit_easing(progress),
        })
    return results

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("frames_dir")
    ap.add_argument("--template", required=True, help="X,Y,W,H crop in the template frame")
    ap.add_argument("--template-frame", type=int, required=True, help="1-based frame number to crop from")
    ap.add_argument("--search", type=int, default=60, help="search radius px (after downscale)")
    ap.add_argument("--downscale", type=int, default=2)
    ap.add_argument("--fps", type=float, default=30.0)
    ap.add_argument("--out", default=None)
    a = ap.parse_args()

    files = sorted(glob.glob(os.path.join(a.frames_dir, "*.png")))
    if not files:
        sys.exit("no png frames found")
    x, y, w, h = [int(v) for v in a.template.split(",")]
    ds = a.downscale
    tpl_full = load_gray(files[a.template_frame - 1], 1)
    tpl = tpl_full[y:y + h, x:x + w]
    tpl = np.asarray(Image.fromarray(tpl).resize((w // ds, h // ds), Image.BILINEAR), dtype=np.float32)
    frames = [load_gray(f, ds) for f in files]
    track = ncc_track(frames, tpl, (x // ds, y // ds), a.search)
    segments = analyze(track, a.fps)
    result = {
        "frames": len(files), "fps": a.fps, "downscale": ds,
        "template": {"frame": a.template_frame, "xywh": [x, y, w, h]},
        "mean_track_score": round(float(np.mean([s for _, _, s in track])), 3),
        "move_segments": segments,
        "note": "easing_fit.closest is the best fit among standard families, "
                "not an exact cubic-bezier recovery",
    }
    text = json.dumps(result, indent=2)
    if a.out:
        open(a.out, "w").write(text)
    print(text)

if __name__ == "__main__":
    main()
