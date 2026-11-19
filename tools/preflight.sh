#!/usr/bin/env bash
# preflight.sh - verify the editing environment and create the workspace layout.
# Also enforces the asset-sourcing ledger rule: every shippable file in
# assets/ needs a row in assets/ledger.md. Exempt: ref_audio.wav (analysis
# only, never shipped) and mixed_audio.wav (derived from ledgered sources).
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

# Asset ledger enforcement (see skills/asset-sourcing). A shippable asset
# with no ledger row fails the preflight: "no ledger row, no render".
ledger_fail=0
ledger="$W/assets/ledger.md"
shippable=()
for a in "$W"/assets/*; do
  [ -e "$a" ] || continue
  base=$(basename "$a")
  case "$base" in
    ref_audio.wav|mixed_audio.wav|ledger.md) continue ;;
  esac
  shippable+=("$base")
done
if [ "${#shippable[@]}" -gt 0 ]; then
  if [ ! -f "$ledger" ]; then
    echo "LEDGER FAIL: $ledger missing - ${#shippable[@]} asset(s) need rows" >&2
    ledger_fail=1
  else
    for base in "${shippable[@]}"; do
      if ! grep -qF -- "$base" "$ledger"; then
        echo "LEDGER FAIL: $base has no row in $ledger" >&2
        ledger_fail=1
      fi
    done
  fi
  if [ "$ledger_fail" -eq 0 ]; then
    echo "ok      asset ledger (${#shippable[@]} asset(s) covered by $ledger)"
  fi
fi

# Optional: a local ffmpeg/ffprobe in the workspace bin always wins on PATH.
export PATH="$(cd "$W" && pwd)/bin:$PATH"

echo "workspace: $W"
if [ "$missing" -ne 0 ]; then
  echo "Install the missing tools, or drop a static ffmpeg build into $W/bin (BtbN/FFmpeg-Builds)." >&2
  exit 1
fi
if [ "$ledger_fail" -ne 0 ]; then
  echo "Add a ledger row per shippable asset (Asset | Source URL | Licence | Downloaded | Used at)." >&2
  exit 1
fi
echo "preflight: PASS"
