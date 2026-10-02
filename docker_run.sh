#!/usr/bin/env bash
# Run a command (default: interactive shell) in the robodiff image with full access to the host:
# all GPUs, all RAM/CPUs (no --memory/--cpus limits), host shared memory and host network.
# Usage: ./docker_run.sh [command ...]
set -e
cd "$(dirname "$0")"
mkdir -p data/.home

TTY_FLAGS=""
if [ -t 0 ]; then TTY_FLAGS="-it"; fi

docker run --rm $TTY_FLAGS \
    --gpus '"device=2"' \
    --ipc=host \
    --ulimit memlock=-1 --ulimit stack=67108864 \
    --network host \
    --user 0 \
    -e HOME=/workspace/data/.home \
    -e WANDB_API_KEY \
    -v "$PWD":/workspace \
    robodiff "${@:-bash}"
