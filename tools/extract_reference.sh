#!/usr/bin/env bash
# extract_reference.sh - pull full study material out of ONE reference video.
# Produces, inside the workspace:
#   video_meta.json            exact width/height/fps/frame count/duration
#   extraction_fps.txt         the fps the frames were extracted at
#   ref_frames/frame_%05d.png  EVERY frame at the extraction fps
#   ref_labeled/frame_%05d.png same frames with "F00001 | 00:00:00.033" burned in
#   contact_sheets/sheet_%03d.png  10x6 labeled tiles (60 frames per sheet)
#   assets/ref_audio.wav       44.1 kHz stereo PCM
#
# Default extraction fps is the video's NATIVE frame rate, so no source frame
# is skipped or duplicated (brief rule: never skip a frame). Pass an explicit
# fps only for a deliberate sample; the script then warns on stderr that the
# extraction is a sample, not full coverage.
#
# Usage: tools/extract_reference.sh <reference.mp4> [workspace_dir] [fps]
set -euo pipefail

REF="${1:?usage: extract_reference.sh <reference.mp4> [workspace_dir] [fps]}"
W="${2:-./recreate_workspace}"

[ -f "$REF" ] || { echo "no such file: $REF" >&2; exit 1; }
mkdir -p "$W"/{ref_frames,ref_labeled,contact_sheets,assets}

ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,r_frame_rate,nb_frames,duration \
  -of json "$REF" > "$W/video_meta.json"

# Native frame rate as a decimal (handles 30000/1001-style rates).
native=$(python3 -c "
from fractions import Fraction
f = Fraction('$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$REF")')
print(int(f) if f.denominator == 1 else float(f))
")

if [ "${3:-}" ]; then
  FPS="$3"
  if [ "$FPS" != "$native" ]; then
    echo "note: extracting at $FPS fps but the source is $native fps - this is a SAMPLE (frames dropped or duplicated by design)" >&2
  fi
else
  FPS="$native"
fi
printf '%s\n' "$FPS" > "$W/extraction_fps.txt"

# Every frame at the extraction fps. Labels burn the extraction-timeline
# position (frame number + timestamp) onto each frame. The plain and labeled
# passes are independent, so they run in parallel.
ffmpeg -hide_banner -loglevel error -y -i "$REF" -vf "fps=$FPS" -start_number 1 \
  "$W/ref_frames/frame_%05d.png" &
pid_plain=$!

# Labeled copies: frame number (+1 so the label matches the file number) and timestamp.
ffmpeg -hide_banner -loglevel error -y -i "$REF" \
  -vf "fps=$FPS,drawtext=text='F%{eif\:n+1\:d\:5} | %{pts\:hms}':x=16:y=16:fontsize=28:fontcolor=white:box=1:boxcolor=black@0.75" \
  -start_number 1 "$W/ref_labeled/frame_%05d.png" &
pid_labeled=$!

# Audio for analysis (not for reuse in the final edit - see LICENSING).
# Silent videos are valid: skip the WAV with a note instead of failing.
if ffprobe -v error -select_streams a:0 -show_entries stream=index -of csv=p=0 "$REF" | grep -q .; then
  ffmpeg -hide_banner -loglevel error -y -i "$REF" -vn -acodec pcm_s16le -ar 44100 -ac 2 \
    "$W/assets/ref_audio.wav"
else
  echo "note: no audio stream in $REF - skipping ref_audio.wav" >&2
fi

wait "$pid_plain" "$pid_labeled"

# Contact sheets: 60 labeled frames each, small enough to read several at once.
ffmpeg -hide_banner -loglevel error -y -i "$W/ref_labeled/frame_%05d.png" \
  -vf "scale=320:-1,tile=10x6" "$W/contact_sheets/sheet_%03d.png"

frames=$(find "$W/ref_frames" -name 'frame_*.png' | wc -l)
sheets=$(find "$W/contact_sheets" -name 'sheet_*.png' | wc -l)
nb=$(python3 -c "import json; print(json.load(open('$W/video_meta.json'))['streams'][0].get('nb_frames','?'))")
echo "extracted $frames frames at $FPS fps (source reports $nb frames) into $W/ref_frames, $sheets contact sheets"
echo "next: tools/audio_events.py $W  then view every contact sheet"
