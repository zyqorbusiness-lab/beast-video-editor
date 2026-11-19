#!/usr/bin/env bash
# side_by_side.sh - build [reference | recreation] QA sheets per brief Step 10.
# Pairs frame N of A with frame N of B side by side, tiles them 5x6, and
# prints a per-pair mean-abs-difference (0.0 = pixel identical; use it to
# prove determinism on re-renders, never to claim a recreation "matches").
#
# Usage: side_by_side.sh <framesA_dir> <framesB_dir> <out_dir> [tile WxH]
# Frames are paired by sorted filename order; counts must match.
set -euo pipefail
A="${1:?usage: side_by_side.sh <framesA> <framesB> <out>}"; B="${2:?}"; O="${3:?}"
mkdir -p "$O/pairs" "$O/sheets"
NA=$(ls "$A"/*.png | wc -l); NB=$(ls "$B"/*.png | wc -l)
[ "$NA" = "$NB" ] || { echo "frame count mismatch: $NA vs $NB" >&2; exit 1; }
i=0
paste <(ls "$A"/*.png) <(ls "$B"/*.png) | while read -r fa fb; do
  i=$((i+1))
  ffmpeg -nostdin -hide_banner -loglevel error -y -i "$fa" -i "$fb" \
    -filter_complex "[0]scale=540:-1[l];[1]scale=540:-1[r];[l][r]hstack" \
    "$(printf "$O/pairs/pair_%05d.png" $i)"
done
ffmpeg -hide_banner -loglevel error -y -framerate 1 -i "$O/pairs/pair_%05d.png" \
  -vf "scale=270:-1,tile=5x6" -frames:v 999 "$O/sheets/sbs_%03d.png"
echo "sheets: $(ls "$O/sheets" | wc -l) in $O/sheets"
# numeric drift: mean abs diff over all pairs (downscaled, grey)
python3 - "$A" "$B" <<'PY'
import glob, sys
import numpy as np
from PIL import Image
A = sorted(glob.glob(sys.argv[1] + '/*.png')); B = sorted(glob.glob(sys.argv[2] + '/*.png'))
diffs = []
for fa, fb in zip(A, B):
    a = np.asarray(Image.open(fa).convert('L').resize((270, 480)), dtype=np.float32)
    b = np.asarray(Image.open(fb).convert('L').resize((270, 480)), dtype=np.float32)
    diffs.append(float(np.abs(a - b).mean()))
d = np.array(diffs)
print(f"pairs={len(d)} mean_abs_diff: mean={d.mean():.3f} max={d.max():.3f} "
      f"identical={(d < 0.5).mean() * 100:.1f}%")
PY
