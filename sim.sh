export DEBIAN_FRONTEND=noninteractive
apt-get update     && apt-get install -y wget git python3 python3-venv libgl1 libglib2.0-0     && apt-get clean     && rm -rf /var/lib/apt/lists/*

adduser --uid 1001 --shell /bin/bash student
cp prepare.py /home/student/prepare.py
cp webui.sh /home/student/webui.sh
chown -R 1001:1001 /home/student


su - student

export PIP_NO_CACHE_DIR=false
COMMANDLINE_ARGS="--skip-torch-cuda-test" bash webui.sh     && rm -rf $(find . -name "*.safetensors")

export GRADIO_SERVER_NAME=0.0.0.0
export GRADIO_SERVER_PORT=7860
mkdir -p /home/student/stable-diffusion-webui/models/Stable-diffusion/

cd stable-diffusion-webui/
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
wget https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors models/Stable-diffusion/
mv sd_xl_*.safetensors ./models/Stable-diffusion/

python launch.py --opt-sdp-attention --no-half-vae

