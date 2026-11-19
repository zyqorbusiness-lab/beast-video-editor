#!/usr/bin/env bash
# extract_reference.sh - pull full study material out of ONE reference video.
# Produces, inside the workspace:
#   video_meta.json            exact width/height/fps/frame count/duration
#   ref_frames/frame_%05d.png  EVERY frame at the study fps (default 30)
#   ref_labeled/frame_%05d.png same frames with "F00001 | 00:00:00.033" burned in
#   contact_sheets/sheet_%03d.png  10x6 labeled tiles (60 frames = 2 s per sheet)
#   assets/ref_audio.wav       44.1 kHz stereo PCM
#
# Usage: tools/extract_reference.sh <reference.mp4> [workspace_dir] [fps]
set -euo pipefail

REF="${1:?usage: extract_reference.sh <video> [workspace] [fps]}"
W="${2:-./recreate_workspace}"
FPS="${3:-30}"

[ -f "$REF" ] || { echo "no such file: $REF" >&2; exit 1; }
mkdir -p "$W"/{ref_frames,ref_labeled,contact_sheets,assets}

ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,r_frame_rate,nb_frames,duration \
  -of json "$REF" > "$W/video_meta.json"

# Every frame at the study fps. Filenames carry the 30fps timeline position.
ffmpeg -hide_banner -loglevel error -y -i "$REF" -vf "fps=$FPS" -start_number 1 \
  "$W/ref_frames/frame_%05d.png"

# Labeled copies: frame number (+1 so the label matches the file number) and timestamp.
ffmpeg -hide_banner -loglevel error -y -i "$REF" \
  -vf "fps=$FPS,drawtext=text='F%{eif\:n+1\:d\:5} | %{pts\:hms}':x=16:y=16:fontsize=28:fontcolor=white:box=1:boxcolor=black@0.75" \
  -start_number 1 "$W/ref_labeled/frame_%05d.png"

# Contact sheets: 60 labeled frames each, small enough to read several at once.
ffmpeg -hide_banner -loglevel error -y -i "$W/ref_labeled/frame_%05d.png" \
  -vf "scale=320:-1,tile=10x6" "$W/contact_sheets/sheet_%03d.png"

# Audio for analysis (not for reuse in the final edit - see LICENSING).
ffmpeg -hide_banner -loglevel error -y -i "$REF" -vn -acodec pcm_s16le -ar 44100 -ac 2 \
  "$W/assets/ref_audio.wav"

frames=$(find "$W/ref_frames" -name 'frame_*.png' | wc -l)
sheets=$(find "$W/contact_sheets" -name 'sheet_*.png' | wc -l)
echo "extracted $frames frames into $frames-dir, $sheets contact sheets"
echo "next: tools/audio_events.py $W  then view every contact sheet"
