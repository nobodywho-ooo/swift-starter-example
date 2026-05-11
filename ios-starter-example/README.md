[![Discord](https://img.shields.io/discord/1308812521456799765?logo=discord&style=flat-square)](https://discord.gg/qhaMc2qCYB)
[![Matrix](https://img.shields.io/badge/Matrix-000?logo=matrix&logoColor=fff)](https://matrix.to/#/#nobodywho:matrix.org)
[![Mastodon](https://img.shields.io/badge/Mastodon-6364FF?logo=mastodon&logoColor=fff&style=flat-square)](https://mastodon.gamedev.place/@nobodywho)
[![Docs](https://img.shields.io/badge/Docs-lightblue?style=flat-square)](https://docs.nobodywho.ooo)

# NobodyWho iOS Starter App

Demonstrates the capabilities of **[NobodyWho](https://github.com/nobodywho-ooo/nobodywho)**, a library designed to run LLMs locally and efficiently on any device.

## Features

- **Chat** — stream responses from a local LLM
- **Tool calling** — give the model access to custom functions (e.g. weather, calculator)
- **Vision & Hearing** — image & audio ingestion with a multimodal model
- **Embeddings & RAG** — semantic search with an embedding model and cross-encoder reranker

## 1. Getting Started

Open the `.xcodeproj` with Xcode and download dependencies.

### 2. Download Models

In production, we recommend downloading models on demand — only when needed (you can use our built-in download method or your own download method). This keeps your app size small. For development, the simplest approach is to download the models ahead of time and bundle them directly in your assets folder (see script below).

#### Automated (Recommended)

**Chat only**
Minimal setup - fast inference, even on old iPhone: `./scripts/download_chat.sh`

**All features**
Chat + vision + hearing + embeddings + reranker
Downloads Gemma 4, which runs well on latest iPhone pro, but might not work or be slow on old iPhone: `./scripts/download_chat_multimodal.sh && ./scripts/download_embedding_rerank.sh`

The scripts download models from Hugging Face, rename them, and place them in the `Assets/` folder inside the project.

#### Download with NobodyWho

Load models directly from Hugging Face using `hf://` URLs (e.g. `hf://owner/repo/model.gguf`). Also supports plain HTTP/HTTPS URLs. Models are cached locally and re-used on subsequent loads. Works on Android with proper cache directory selection.

Example:

```swift
// Download from HuggingFace (cached automatically)
let model = try await Model.load(
    modelPath: "https://huggingface.co/NobodyWho/Qwen_Qwen3-0.6B-GGUF/resolve/main/Qwen_Qwen3-0.6B-Q4_K_M.gguf",
    useGpu: true
)
```

#### Manual Download

You can use any `.gguf` model from [Hugging Face](https://huggingface.co/models).

**Chat models** — some worth considering: Qwen, Gemma, LFM, and Ministral, available in [this collection](https://huggingface.co/unsloth/collections).

**Multimodal models** — some examples by modality: [Vision](https://huggingface.co/LiquidAI/LFM2-VL-450M-GGUF/tree/main), [Hearing](https://huggingface.co/ggml-org/ultravox-v0_5-llama-3_2-1b-GGUF/tree/main), [Vision + Hearing](https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/tree/main)

Compatibility notes:

- Most GGUF models will work, but some may fail due to formatting issues. Here are some [models](https://huggingface.co/NobodyWho/collections) we have made sure they work perfectly.
- Models under 1 GB tend to run smoothly. As a general rule, the device should have at least twice the available RAM as the model file size. Note that available RAM differs from total RAM — iOS typically reserves around 1–2 GB for the kernel and system processes.