# Training/eval image for the simulation benchmarks (robomimic, Push-T, etc.).
# The repo itself is mounted at /workspace at runtime (see docker_run.sh), so code edits need no rebuild.
FROM nvidia/cuda:11.6.2-base-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive \
    NVIDIA_DRIVER_CAPABILITIES=all

# mujoco-py system dependencies (see README) + compiler for its Cython extension
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget ca-certificates git build-essential \
        libosmesa6-dev libgl1-mesa-glx libglfw3 libglew-dev patchelf \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O /tmp/miniforge.sh \
    && bash /tmp/miniforge.sh -b -p /opt/conda \
    && rm /tmp/miniforge.sh
ENV PATH=/opt/conda/envs/robodiff/bin:/opt/conda/bin:$PATH

COPY conda_environment.yaml /tmp/conda_environment.yaml
RUN mamba env create -f /tmp/conda_environment.yaml && conda clean -afy

# mujoco-py compiles itself on first import and takes a file lock in its package dir on every import,
# so build it now and make that dir writable for the non-root user the container runs as.
RUN python -c "import mujoco_py" \
    && chmod -R a+rwX "$(python -c 'import os, mujoco_py; print(os.path.dirname(mujoco_py.__file__))')"

WORKDIR /workspace
CMD ["bash"]
