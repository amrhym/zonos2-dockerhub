#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8000}"
OUT_PCM="${OUT_PCM:-/tmp/zonos2-smoke.pcm}"
OUT_WAV="${OUT_WAV:-/tmp/zonos2-smoke.wav}"

curl -fsS "$BASE_URL/tts/capabilities"
echo

curl -fsS \
  -H 'Content-Type: application/json' \
  -X POST "$BASE_URL/tts/generate" \
  -d '{"text":"هلا والله، كيف أقدر أخدمك اليوم؟","text_normalization":false,"stream":true,"max_tokens":512,"seed":42}' \
  -o "$OUT_PCM"

ffmpeg -hide_banner -loglevel error \
  -f f32le -ar 44100 -ac 1 \
  -i "$OUT_PCM" \
  -y "$OUT_WAV"

file "$OUT_WAV" || true
ls -lh "$OUT_PCM" "$OUT_WAV"
