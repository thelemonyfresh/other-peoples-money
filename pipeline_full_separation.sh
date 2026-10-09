#!/usr/bin/env bash
set -e

DIR="/Users/dan/src/other_peoples_money"
SRC_VIDEO="$DIR/other_peoples_money_unedited.mp4"
TEMP_AUDIO="$DIR/other_peoples_money_full.flac"
OUT_DIR="$DIR/separated/full"
VENV_DEMUCS="$DIR/.venv/bin/demucs"

echo "=== [1/5] Extracting audio to FLAC ==="
ffmpeg -y -i "$SRC_VIDEO" -vn -c:a flac "$TEMP_AUDIO"

echo "=== [2/5] Running Demucs Source Separation (CPU multithreaded) ==="
mkdir -p "$OUT_DIR"
"$VENV_DEMUCS" -d cpu -j 4 --two-stems vocals --flac -o "$OUT_DIR" "$TEMP_AUDIO"

VOCALS_FLAC="$OUT_DIR/htdemucs/other_peoples_money_full/vocals.flac"
NO_VOCALS_FLAC="$OUT_DIR/htdemucs/other_peoples_money_full/no_vocals.flac"

echo "=== [3/5] Encoding web audio stems ==="
mkdir -p "$DIR/web/media"
ffmpeg -y -i "$VOCALS_FLAC" -c:a aac -b:a 192k "$DIR/web/media/full_dialogue.m4a"
ffmpeg -y -i "$NO_VOCALS_FLAC" -c:a aac -b:a 192k "$DIR/web/media/full_soundtrack.m4a"

echo "=== [4/5] Assembling final multi-track MP4 video file ==="
ffmpeg -y \
  -i "$SRC_VIDEO" \
  -i "$VOCALS_FLAC" \
  -i "$NO_VOCALS_FLAC" \
  -map 0:v:0 \
  -map 0:a:0 \
  -map 1:a:0 \
  -map 2:a:0 \
  -c:v copy \
  -c:a aac -b:a 256k \
  -metadata:s:a:0 language=eng -metadata:s:a:0 title="Original Mix" -metadata:s:a:0 handler_name="Original Mix" \
  -metadata:s:a:1 language=eng -metadata:s:a:1 title="Dialogue Only" -metadata:s:a:1 handler_name="Dialogue Only" \
  -metadata:s:a:2 language=eng -metadata:s:a:2 title="Soundtrack & SFX" -metadata:s:a:2 handler_name="Soundtrack & SFX" \
  -movflags +faststart -map_chapters -1 \
  "$DIR/other_peoples_money_multitrack.mp4"

echo "=== [5/5] Cleaning up temp audio ==="
rm -f "$TEMP_AUDIO"

echo "=== COMPLETE! All stems and multi-track MP4 ready ==="
