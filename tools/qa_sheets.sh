#!/usr/bin/env bash
# qa_sheets.sh - side-by-side [Reference | Recreation] QA sheets.
# Extracts the render at the study fps, stacks each reference frame next to the
# matching render frame, and tiles the pairs 5x6 so drift is visible at a glance.
#
# Usage: tools/qa_sheets.sh <rendered.mp4> [workspace_dir] [fps]
# fps defaults to the extraction fps recorded by extract_reference.sh
# ($workspace/extraction_fps.txt), falling back to 30.
set -euo pipefail

OUT="${1:?usage: qa_sheets.sh <rendered.mp4> [workspace_dir] [fps]}"
W="${2:-./recreate_workspace}"
if [ "${3:-}" ]; then
  FPS="$3"
elif [ -f "$W/extraction_fps.txt" ]; then
  FPS=$(cat "$W/extraction_fps.txt")
else
  FPS=30
fi

[ -f "$OUT" ] || { echo "no such file: $OUT" >&2; exit 1; }
[ -d "$W/ref_labeled" ] || { echo "run extract_reference.sh first" >&2; exit 1; }
mkdir -p "$W/output"

ffmpeg -hide_banner -loglevel error -y -i "$OUT" -vf "fps=$FPS" -start_number 1 \
  "$W/output/out_%05d.png"

ffmpeg -hide_banner -loglevel error -y \
  -i "$W/ref_labeled/frame_%05d.png" -i "$W/output/out_%05d.png" \
  -filter_complex "[0:v]scale=360:-1[r];[1:v]scale=360:-1[o];[r][o]hstack=inputs=2" \
  -start_number 1 "$W/output/diff_%05d.png"

ffmpeg -hide_banner -loglevel error -y -i "$W/output/diff_%05d.png" -vf "tile=5x6" \
  "$W/output/qa_sheet_%03d.png"

ref_frames=$(find "$W/ref_labeled" -name 'frame_*.png' | wc -l)
out_frames=$(find "$W/output" -name 'out_*.png' | wc -l)
echo "reference frames: $ref_frames, rendered frames: $out_frames"
if [ "$ref_frames" != "$out_frames" ]; then
  echo "FRAME COUNT MISMATCH - the render does not match the reference length" >&2
  exit 1
fi
echo "QA sheets written to $W/output/qa_sheet_*.png - view every sheet before delivery"
