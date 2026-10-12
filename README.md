# Whisper Diarization

OpenAI-compatible WhisperX service for speaker-aware transcription.

## Nix

The flake exports `packages.<system>.default` and `packages.<system>.whisper-diarization`, both providing the `whisper-diarization` command. `lib.<system>.mkPackage { python = ...; }` lets a downstream NixOS service provide its CUDA-enabled Python environment while keeping this repository responsible for the Python source and launcher.
