#!/bin/bash

set -e

echo "============================================"
echo "  HiveCompute AI-Toolkit setup (Ubuntu 24.04)"
echo "============================================"

# Gde ćemo da radimo
WORKDIR="$HOME/workspace"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "[1/6] System update + osnovni paketi..."
sudo apt update -y
sudo apt install -y git python3-venv python3-pip python3-dev build-essential ca-certificates curl gnupg

echo "[2/6] Instalacija Node.js 20 (Nodesource repo)..."
# ako postoji stari node iz Ubuntu repoa, može da pravi probleme
sudo apt purge -y nodejs npm 2>/dev/null || true

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "Node version: $(node -v)"
echo "npm version: $(npm -v)"

echo "[3/6] Kloniranje / update AI-Toolkit repoa..."
if [ ! -d "ai-toolkit" ]; then
    git clone https://github.com/ostris/ai-toolkit.git
fi
cd ai-toolkit
git pull || true

echo "[4/6] Python venv + Torch 2.7.0 (cu126)..."
python3 -m venv venv
source venv/bin/activate

pip3 install --upgrade pip
# zvanična preporuka iz README-a: torch 2.7.0 + cu126 
pip3 install --no-cache-dir torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0 --index-url https://download.pytorch.org/whl/cu126

echo "[5/6] AI-Toolkit requirements..."
pip3 install --no-cache-dir -r requirements.txt

echo "[6/6] Pokretanje UI-ja (port 8675) u pozadini..."
cd ui

# ako hoćeš auth password – promeni ovde
export AI_TOOLKIT_AUTH=${AI_TOOLKIT_AUTH:-changeme123}

npm install

# UI se po defaultu diže na 0.0.0.0:8675 
# pokrećemo ga u pozadini da ne blokira shell
nohup npm run build_and_start > "$WORKDIR/ai-toolkit-ui.log" 2>&1 &

echo "============================================"
echo " AI-Toolkit UI se startuje na portu 8675."
echo " Prati log: tail -f $WORKDIR/ai-toolkit-ui.log"
echo "============================================"
