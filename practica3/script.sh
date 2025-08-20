#!/bin/bash
set -e

echo "[1/5] Eliminando instalaciones previas..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt-get remove -y "$pkg" || true
done

echo "[2/5] Preparando repositorio oficial de Docker..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Detectar codename correcto
source /etc/os-release
CODENAME="${UBUNTU_CODENAME:-$VERSION_CODENAME}"

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu ${CODENAME} stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[3/5] Instalando Docker..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[4/5] Añadiendo usuario al grupo docker..."
sudo usermod -aG docker "$USER"

echo "[5/5] Verificando instalación..."
docker --version
docker compose version

echo "✅ Docker instalado en VM."
echo "⚠️ Recuerda cerrar sesión o reiniciar la VM para aplicar el grupo 'docker'."

