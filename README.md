# ZONOS2 Ready Runtime Container

Ready container for validating Zyphra ZONOS2 on NVIDIA GPUs.

The image starts the official ZONOS2 HTTP server on port `8000`.

Important endpoints:

- `GET /tts/capabilities`
- `POST /tts/generate`
- `POST /v1/audio/speech`
- `GET /tts/speakers`

## Docker Hub Image

```text
amrhym/zonos2-b200:latest
```

The default image includes runtime dependencies but does not bake the full
model weights. On first start it downloads/cache-loads `Zyphra/ZONOS2` and the
speaker embedding model into `/models/.cache`.

## Build Settings

GitHub Actions builds and pushes this image to Docker Hub.

```text
Dockerfile: /Dockerfile
Build context: /
Platform: linux/amd64
Tag: latest
```

## RunPod Test

```text
Image: amrhym/zonos2-b200:latest
GPU: H100/H200/B200
HTTP port: 8000
Container disk: 120 GB minimum
Command: empty
Arguments: empty
```

The first startup can take several minutes because it downloads model files.

Test:

```bash
curl -fsS https://<pod-id>-8000.proxy.runpod.net/tts/capabilities

curl -fsS \
  -H 'Content-Type: application/json' \
  -X POST https://<pod-id>-8000.proxy.runpod.net/tts/generate \
  -d '{"text":"هلا والله، كيف أقدر أخدمك اليوم؟","text_normalization":false,"stream":true,"max_tokens":512,"seed":42}' \
  -o output.pcm

ffmpeg -f f32le -ar 44100 -ac 1 -i output.pcm output.wav
```

## Optional Weight-Baked Build

Use this only on a large builder:

```bash
docker build \
  --build-arg PRELOAD_MODEL=true \
  -t amrhym/zonos2-b200:with-weights .
```
