# syntax=docker/dockerfile:1.7

# This RunPod image already contains Python, CUDA 12.8, Torch 2.9.1, and
# matching CUDA runtime libraries. It is the same family we validated manually
# with ZONOS2 on RunPod.
ARG BASE_IMAGE=runpod/pytorch:1.0.3-cu1281-torch291-ubuntu2404
FROM ${BASE_IMAGE}

ARG ZONOS2_REF=main
ARG PRELOAD_MODEL=false

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/models/.cache \
    XDG_CACHE_HOME=/models/.cache \
    ZONOS2_MODEL_PATH=Zyphra/ZONOS2 \
    ZONOS2_DEFAULT_VOICES_DIR=/opt/ZONOS2/default_voices \
    ZONOS2_HOST=0.0.0.0 \
    PORT=8000 \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    ffmpeg \
    git \
    git-lfs \
    libsndfile1 \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip setuptools wheel packaging ninja

# flashinfer-jit-cache has a CUDA 12.8 wheel published on GitHub; pip's normal
# index does not always resolve the local +cu128 build metadata correctly.
RUN python3 -m pip install \
    "nvidia-cuda-runtime>=13,<14" \
    "https://github.com/flashinfer-ai/flashinfer/releases/download/v0.5.3/flashinfer_jit_cache-0.5.3+cu128-cp39-abi3-manylinux_2_28_x86_64.whl"

RUN git clone --depth 1 --branch "${ZONOS2_REF}" https://github.com/Zyphra/ZONOS2.git /opt/ZONOS2

WORKDIR /opt/ZONOS2

RUN python3 -m pip install .

# Keep the default Docker Hub image smaller and faster to publish. Set
# PRELOAD_MODEL=true only when building on a large local/cloud builder and you
# want model weights baked into the image.
RUN if [ "${PRELOAD_MODEL}" = "true" ]; then \
      python3 -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='Zyphra/ZONOS2', cache_dir='/models/.cache'); snapshot_download(repo_id='marksverdhei/Qwen3-Voice-Embedding-12Hz-1.7B', cache_dir='/models/.cache')" ; \
    fi

COPY start.sh /app/start.sh
COPY smoke_test.sh /app/smoke_test.sh
COPY NOTICE.md /app/NOTICE.md

RUN chmod +x /app/start.sh /app/smoke_test.sh && \
    python3 - <<'PY'
import importlib.metadata
import torch
print("ZONOS2", importlib.metadata.version("ZONOS2"))
print("torch", torch.__version__)
print("cuda build", torch.version.cuda)
PY

EXPOSE 8000

CMD ["/app/start.sh"]
