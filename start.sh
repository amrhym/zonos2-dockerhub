#!/usr/bin/env bash
set -euo pipefail

exec python3 -m zonos2 \
  --model-path "${ZONOS2_MODEL_PATH:-Zyphra/ZONOS2}" \
  --host "${ZONOS2_HOST:-0.0.0.0}" \
  --port "${PORT:-8000}" \
  --tts-default-voices-dir "${ZONOS2_DEFAULT_VOICES_DIR:-/opt/ZONOS2/default_voices}"
