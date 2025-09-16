#!/bin/bash

# Script de aprovisionamiento para Docker y Docker Compose
# Instala Docker y Docker Compose sin necesidad de sudo

echo "=== Iniciando aprovisionamiento de Docker ==="

# Actualizar paquetes
sudo apt-get update -y

# Instalar dependencias
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Agregar clave GPG oficial de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Configurar repositorio de Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar repositorios
sudo apt-get update -y

# Instalar Docker Engine, containerd y Docker Compose
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Agregar usuario vagrant al grupo docker (para usar sin sudo)
sudo usermod -aG docker vagrant

# Habilitar Docker para iniciar automáticamente
sudo systemctl enable docker
sudo systemctl start docker

# Verificar instalación
echo "=== Verificando instalación ==="
sudo docker --version
sudo docker compose version

echo "=== Aprovisionamiento completado ==="
echo "NOTA: Reinicia la sesión (vagrant reload) para usar docker sin sudo"