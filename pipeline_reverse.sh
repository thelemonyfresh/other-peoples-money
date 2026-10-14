#!/usr/bin/env bash
set -e

# Builds time-reversed copies of the web media for VHS-style rewind.
# Inputs are the files served by the player (see pipeline_full_separation.sh for the stems).
# Override DIR / JOBS from the environment, e.g. DIR=$PWD JOBS=8 ./pipeline_reverse.sh

DIR="${DIR:-/Users/dan/src/other_peoples_money}"
MEDIA="$DIR/web/media"
WORK="$DIR/separated/reverse"
JOBS="${JOBS:-4}"

SRC_VIDEO="$MEDIA/full_video.mp4"
REV_VIDEO="$MEDIA/full_video_rev.mp4"

# ffmpeg's reverse filters buffer the whole input in memory, so everything is
# reversed in short chunks and the chunks are joined back in reverse order.

echo "=== [1/5] Splitting video at source keyframes (stream copy, no re-encode) ==="
rm -rf "$WORK"
mkdir -p "$WORK/video" "$WORK/audio"
ffmpeg -v error -y -i "$SRC_VIDEO" -map 0:v:0 -c copy \
  -f segment -segment_time 0.01 -reset_timestamps 1 \
  "$WORK/video/fwd_%05d.mp4"

echo "=== [2/5] Reversing video chunks ($JOBS parallel jobs) ==="
ls "$WORK/video"/fwd_*.mp4 | xargs -P "$JOBS" -I{} sh -c '
  ffmpeg -v error -y -i "$1" -vf reverse -an -fps_mode passthrough \
    -c:v libx264 -preset slow -crf 21 -g 48 -pix_fmt yuv420p \
    "$(dirname "$1")/rev_$(basename "$1" | sed s/^fwd_//)" && rm "$1"
' _ {}

echo "=== [3/5] Joining reversed video ==="
ls "$WORK/video"/rev_*.mp4 | sort -r | sed "s/^/file '/; s/$/'/" > "$WORK/video/list.txt"
ffmpeg -v error -y -f concat -safe 0 -i "$WORK/video/list.txt" -c copy -movflags +faststart "$REV_VIDEO"

echo "=== [4/5] Reversing audio stems ==="
for STEM in dialogue soundtrack; do
  STEM_DIR="$WORK/audio/$STEM"
  mkdir -p "$STEM_DIR"
  ffmpeg -v error -y -i "$MEDIA/full_$STEM.m4a" -c:a pcm_s16le \
    -f segment -segment_time 30 "$STEM_DIR/fwd_%05d.wav"
  for SEG in "$STEM_DIR"/fwd_*.wav; do
    ffmpeg -v error -y -i "$SEG" -af areverse "$STEM_DIR/rev_$(basename "$SEG" | sed s/^fwd_//)"
    rm "$SEG"
  done
  ls "$STEM_DIR"/rev_*.wav | sort -r | sed "s/^/file '/; s/$/'/" > "$STEM_DIR/list.txt"
  ffmpeg -v error -y -f concat -safe 0 -i "$STEM_DIR/list.txt" -c:a aac -b:a 192k -movflags +faststart \
    "$MEDIA/full_${STEM}_rev.m4a"
  rm -rf "$STEM_DIR"
done

echo "=== [5/5] Verifying reversed files match the originals ==="
probe() { ffprobe -v error -select_streams "$2" -show_entries "stream=$3" -of csv=p=0 "$1"; }
printf "%-28s %14s %14s\n" "" "ORIGINAL" "REVERSED"
printf "%-28s %14s %14s\n" "video frames" "$(probe "$SRC_VIDEO" v:0 nb_frames)" "$(probe "$REV_VIDEO" v:0 nb_frames)"
printf "%-28s %14s %14s\n" "video duration (s)" "$(probe "$SRC_VIDEO" v:0 duration)" "$(probe "$REV_VIDEO" v:0 duration)"
for STEM in dialogue soundtrack; do
  printf "%-28s %14s %14s\n" "$STEM duration (s)" \
    "$(probe "$MEDIA/full_$STEM.m4a" a:0 duration)" "$(probe "$MEDIA/full_${STEM}_rev.m4a" a:0 duration)"
done
rm -rf "$WORK"

echo "=== COMPLETE! Upload full_video_rev.mp4, full_dialogue_rev.m4a, full_soundtrack_rev.m4a alongside the originals ==="
