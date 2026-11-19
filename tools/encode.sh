#!/usr/bin/env bash
# encode.sh - deterministic frames + mixed audio -> delivery MP4.
# libx264, yuv420p, crf 16, aac 192k, +faststart.
# With BLEND=1 it expects a 2x-fps render and blends frame pairs into motion
# blur (tmix) while keeping the output at the base fps. Never blend across a
# hard cut - render those segments separately if the timeline needs both.
#
# Usage: tools/encode.sh <workspace_dir> <out.mp4> [fps] [audio.wav]
# Env:   BLEND=1  blend a 2x-fps render down to fps
set -euo pipefail

W="${1:?usage: encode.sh <workspace> <out.mp4> [fps] [audio.wav]}"
OUT="${2:?usage: encode.sh <workspace> <out.mp4> [fps] [audio.wav]}"
FPS="${3:-30}"
AUDIO="${4:-$W/assets/mixed_audio.wav}"

FRAMES="$W/render_frames/frame_%05d.png"
[ -f "$(printf "$W/render_frames/frame_%05d.png" 1)" ] || { echo "no rendered frames in $W/render_frames" >&2; exit 1; }

if [ "${BLEND:-0}" = "1" ]; then
  SRC_FPS=$((FPS * 2))
  FILTER="tmix=frames=2,select='not(mod(n\,2))',setpts=N/${FPS}/TB"
else
  SRC_FPS=$FPS
  FILTER="null"
fi

if [ -f "$AUDIO" ]; then
  ffmpeg -hide_banner -loglevel error -y -framerate "$SRC_FPS" -i "$FRAMES" -i "$AUDIO" \
    -vf "$FILTER" -r "$FPS" \
    -c:v libx264 -pix_fmt yuv420p -crf 16 -preset slow \
    -c:a aac -b:a 192k -shortest -movflags +faststart "$OUT"
else
  echo "note: $AUDIO not found, encoding video-only" >&2
  ffmpeg -hide_banner -loglevel error -y -framerate "$SRC_FPS" -i "$FRAMES" \
    -vf "$FILTER" -r "$FPS" \
    -c:v libx264 -pix_fmt yuv420p -crf 16 -preset slow -movflags +faststart "$OUT"
fi

ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames,duration -of json "$OUT"
echo "encoded: $OUT"
