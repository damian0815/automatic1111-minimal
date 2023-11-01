FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y wget git python3 python3-venv libgl1 libglib2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --uid 1001 --shell /bin/bash student

COPY prepare.py /home/student/prepare.py
COPY webui.sh /home/student/webui.sh
RUN chown -R 1001:1001 /home/student

USER 1001
WORKDIR /home/student

ENV PIP_NO_CACHE_DIR=false

RUN COMMANDLINE_ARGS="--skip-torch-cuda-test" bash webui.sh \
    && rm -rf $(find . -name "*.safetensors")

WORKDIR /home/student/stable-diffusion-webui

ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS="--allow-code --medvram --xformers --enable-insecure-extension-access --api"
EXPOSE 7860

ENV GRADIO_SERVER_NAME=0.0.0.0
ENV GRADIO_SERVER_PORT=7860

RUN mkdir -p /home/student/stable-diffusion-webui/models/Stable-diffusion/
CMD ["bash", "-c", "source /home/student/stable-diffusion-webui/venv/bin/activate && ls /data && cp /data/weights/* /home/student/stable-diffusion-webui/models/Stable-diffusion/ || echo NOPE && python launch.py"]
