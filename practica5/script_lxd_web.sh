#!/usr/bin/env bash
set -euo pipefail

echo "[LXD] Instalando LXD y preparando entorno"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y snapd curl
export PATH="/snap/bin:$PATH"

if ! command -v lxd >/dev/null 2>&1; then
  sudo snap install lxd
  sleep 10
fi

# Espera a que el daemon esté listo con timeout
timeout 60 sudo lxd waitready || true

# Inicializa LXD si hace falta
if ! sudo lxc info >/dev/null 2>&1; then
  sudo lxd init --auto || true
fi

# Crear red por defecto si no existe
if ! sudo lxc network list | grep -q "lxdbr0"; then
  echo "[LXD] Creando red lxdbr0"
  sudo lxc network create lxdbr0
fi

# Asegura storage pool 'default'
if ! sudo lxc storage show default >/dev/null 2>&1; then
  echo "[LXD] Creando storage pool 'default' (dir)"
  sudo lxc storage create default dir
fi

# Asegura que el profile 'default' tiene un disk root que use ese pool
if ! sudo lxc profile show default | grep -qE '^\s+root:'; then
  echo "[LXD] Añadiendo disk root al profile 'default'"
  sudo lxc profile device add default root disk path=/ pool=default
fi

# (Opcional) añade vagrant al grupo lxd
if id -u vagrant >/dev/null 2>&1; then
  sudo usermod -aG lxd vagrant || true
fi

echo "[LXD] Creando contenedor 'web1' (Ubuntu 22.04) si no existe"
if ! sudo lxc info web1 >/dev/null 2>&1; then
  # Cerrar STDIN evita que LXD intente leer YAML accidentalmente
  sudo lxc launch ubuntu:22.04 web1 </dev/null
  # Conectar el contenedor a la red
  sudo lxc network attach lxdbr0 web1 eth0
  sudo lxc restart web1
  sleep 10
fi

echo "[WEB] Instalando Nginx dentro del contenedor y dejando página"
sudo lxc exec web1 -- bash -lc 'apt-get update -y && apt-get install -y nginx'
sudo lxc exec web1 -- bash -lc "cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang='es'>
<head><meta charset='utf-8'><title>Mi sitio LXD</title></head>
<body style='font-family:system-ui; margin:2rem'>
  <h1>¡Hola desde LXD!</h1>
  <p>Contenedor <strong>web1</strong> sirviendo Nginx.</p>
</body>
</html>
HTML"
sudo lxc exec web1 -- systemctl enable --now nginx

echo "[LXD] Publicando 80 del contenedor como 8080 en la VM"
if ! sudo lxc config device show web1 | grep -q '^webproxy:'; then
  sudo lxc config device add web1 webproxy proxy listen=tcp:0.0.0.0:8080 connect=tcp:127.0.0.1:80
fi

# Abrir 8080 si UFW está activo
if command -v ufw >/dev/null 2>&1; then
  sudo ufw allow 8080/tcp || true
fi

echo "[CHECK] Probando desde la VM (localhost:8080)"
if curl -fsS http://127.0.0.1:8080 >/dev/null; then
  echo "OK: Responde en 127.0.0.1:8080"
else
  echo "WARNING: No respondió en 127.0.0.1:8080" >&2
fi

IP=$(ip -4 -br addr | awk '/192\.168\./{print $3; exit}' | sed 's#/.*##' || true)
echo "------------------------------------------------------------"
echo "Contenedor: web1 (Ubuntu 22.04) con Nginx"
echo "En la VM:  http://127.0.0.1:8080"
echo "Desde tu host: http://${IP:-192.168.X.X}:8080"

