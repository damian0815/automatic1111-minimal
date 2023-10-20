FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y libgl1 libglib2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m webui

# Switch to 'myuser'
USER webui

WORKDIR /home/webui

RUN wget -q https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh \
    && bash webui.sh \
    && pip install -r stable-diffusion-webui/requirements_versions.txt \
    && rm -rf stable-diffusion-webui/stable-diffusion-webui.git

COPY prepare.py /home/webui/stable-diffusion-webui/prepare.py

RUN COMMANDLINE_ARGS="--skip-torch-cuda-test" python stable-diffusion-webui/prepare.py \
    && rm -rf $(find . -name "*.safetensors") \
    && rm -rf $(find . -name ".git")

WORKDIR /home/webui/stable-diffusion-webui

ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS="--allow-code --lovram --xformers --enable-insecure-extension-access --api"
EXPOSE 7860

CMD python launch.py
