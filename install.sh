#!/bin/bash

set -e

echo "========================================================="
echo " MASSCOMPUTE AI-TOOLKIT AUTO INSTALLER (Ubuntu 22.04)"
echo "========================================================="

echo "[1/7] Updating system..."
sudo apt update -y
sudo apt install -y curl wget gnupg lsb-release ca-certificates

echo "[2/7] Installing Docker (if not installed)..."
if ! command -v docker &> /dev/null
then
    sudo apt install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
fi

echo "[3/7] Installing NVIDIA Container Toolkit..."
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -fsSL https://nvidia.github.io/libnvidia-container/ubuntu$(lsb_release -rs)/libnvidia-container.list | \
  sudo tee /etc/apt/sources.list.d/libnvidia-container.list

sudo apt update -y
sudo apt install -y nvidia-container-toolkit

echo "[4/7] Configuring NVIDIA runtime..."
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo "[5/7] Removing old AI-Toolkit containers..."
sudo docker stop $(sudo docker ps -q --filter "ancestor=ostris/aitoolkit:latest") 2>/dev/null || true
sudo docker rm $(sudo docker ps -aq --filter "ancestor=ostris/aitoolkit:latest") 2>/dev/null || true

echo "[6/7] Pulling AI-Toolkit image..."
sudo docker pull ostris/aitoolkit:latest

echo "[7/7] Starting AI-Toolkit..."
sudo docker run -d \
  --name aitoolkit \
  --gpus all \
  --shm-size 10g \
  --network=host \
  ostris/aitoolkit:latest

SERVER_IP=$(curl -s ifconfig.me)

echo "========================================================="
echo " AI-Toolkit IS RUNNING!"
echo " Open in browser:"
echo "   http://$SERVER_IP:8675"
echo "========================================================="
