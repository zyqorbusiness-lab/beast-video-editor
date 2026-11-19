#!/usr/bin/env bash
# preflight.sh - verify the editing environment and create the workspace layout.
# Usage: tools/preflight.sh [workspace_dir]   (default: ./recreate_workspace)
set -euo pipefail

W="${1:-./recreate_workspace}"
mkdir -p "$W"/{bin,ref_frames,ref_labeled,contact_sheets,assets,composition,render_frames,output}

missing=0
need() {
  if command -v "$1" >/dev/null 2>&1; then
    printf 'ok      %s (%s)\n' "$1" "$(command -v "$1")"
  else
    printf 'MISSING %s\n' "$1"
    missing=1
  fi
}

need ffmpeg
need ffprobe
need python3
need node

python3 - <<'PY' || missing=1
import sys
mods = []
for m in ("numpy", "PIL"):
    try:
        __import__(m)
        mods.append(m + " ok")
    except ImportError:
        mods.append(m + " MISSING")
        sys.exit(1)
print("ok      python3 " + ", ".join(mods))
PY

# Optional: a local ffmpeg/ffprobe in the workspace bin always wins on PATH.
export PATH="$(cd "$W" && pwd)/bin:$PATH"

echo "workspace: $W"
if [ "$missing" -ne 0 ]; then
  echo "Install the missing tools, or drop a static ffmpeg build into $W/bin (BtbN/FFmpeg-Builds)." >&2
  exit 1
fi
echo "preflight: PASS"
