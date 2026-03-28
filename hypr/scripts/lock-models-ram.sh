#!/usr/bin/env bash
# Lock Ollama model blobs in RAM at startup so they load fast from RAM → VRAM
vmtouch -dl /var/lib/ollama/blobs/sha256-b559938ab7a0392fc9ea9675b82280f2a15669ec3e0e0fc491c9cb0a7681cf94
