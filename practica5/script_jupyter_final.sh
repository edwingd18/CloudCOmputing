#!/usr/bin/env bash
set -euo pipefail

echo "[Jupyter] Instalación optimizada"
export DEBIAN_FRONTEND=noninteractive

# Instalar solo pip básico
sudo apt-get update -y
sudo apt-get install -y python3-pip --no-install-recommends

# Crear directorio de trabajo
sudo mkdir -p /opt/jupyter

echo "[Jupyter] Instalando JupyterLab (esto puede tomar varios minutos)"
# Instalar con timeout largo para evitar fallos
timeout 600 sudo python3 -m pip install jupyterlab || {
    echo "Error: Timeout o fallo en instalación de JupyterLab"
    exit 1
}

echo "[Jupyter] Creando servicio systemd"
sudo tee /etc/systemd/system/jupyter.service >/dev/null <<'EOF'
[Unit]
Description=Jupyter Lab
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/jupyter
ExecStart=/usr/local/bin/jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ServerApp.token='' --ServerApp.password=''
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar el servicio
sudo systemctl daemon-reload
sudo systemctl enable jupyter
sudo systemctl start jupyter

# Esperar un momento para que inicie
sleep 8

# Mostrar estado
if sudo systemctl is-active --quiet jupyter; then
    echo "=== JUPYTER FUNCIONANDO ==="
    # Obtener IP
    IP=$(hostname -I | awk '{print $2}' || echo "192.168.100.3")
    echo "Accede desde tu navegador a: http://${IP}:8888"
else
    echo "=== WARNING: Jupyter no pudo iniciar ==="
    sudo systemctl status jupyter --no-pager -l
fi
