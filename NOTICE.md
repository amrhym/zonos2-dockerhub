# ZONOS2 Runtime Image Notice

This image packages the public ZONOS2 runtime from Zyphra and starts the native
ZONOS2 TTS HTTP server.

Licensing summary:

- ZONOS2 model card on Hugging Face lists `apache-2.0`.
- The ZONOS2 GitHub repository states the runtime is MIT and includes third
  party components under their own licenses.
- The image does not bake model weights by default. It downloads/cache-loads
  model files at runtime under `/models/.cache` unless built with
  `PRELOAD_MODEL=true`.

Primary upstream sources:

- https://huggingface.co/Zyphra/ZONOS2
- https://github.com/Zyphra/ZONOS2
