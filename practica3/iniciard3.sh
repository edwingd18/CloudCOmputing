#!/usr/bin/env bash
set -e


mkdir -p /home/vagrant/test_docker3
cd /home/vagrant/test_docker3

# Clonar repo
if [ ! -d docker-flask-example ]; then
  git clone https://github.com/omondragon/docker-flask-example
fi

cd docker-flask-example

# Detectar archivo principal
if [ -f app/app.py ]; then
  TARGET=app/app.py
else
  TARGET=app.py
fi

# 1) Asegurar que el import tenga jsonify
if grep -q '^from flask import Flask$' "$TARGET"; then
  # reemplaza "Flask" por "Flask, jsonify"
  sed -i 's/^from flask import Flask$/from flask import Flask, jsonify/' "$TARGET"
fi
# si aún no hay jsonify en ningún import de flask, lo añadimos en la primera línea
if ! grep -q 'from flask import .*jsonify' "$TARGET"; then
  sed -i '1i from flask import jsonify' "$TARGET"
fi

# 2) Insertar el bloque /health justo antes de if __main__ (si no existe ya)
if ! grep -q '@app.route("/health")' "$TARGET" && ! grep -q "@app.route('/health')" "$TARGET"; then
  awk '
    BEGIN {
      block = "\n# --- added by provisioner ---\n@app.route(\"/health\")\n" \
              "def health():\n" \
              "    return jsonify(status=\"ok\"), 200\n"
    }
    # cuando encontremos la línea del if __main__, primero imprimimos el bloque y luego la línea
    /^if __name__ == [\"\047].*__main__[\"\047][ ]*:/ {
      print block
      print
      next
    }
    { print }
  ' "$TARGET" > "$TARGET.tmp" && mv "$TARGET.tmp" "$TARGET"
fi
# ========================================================================================

# Correr el flask con docker
docker rm -f flask >/dev/null 2>&1 || true
docker build -t flask-web .
docker run -d --name flask -p 5000:5000 flask-web

# ---- Consul SERVER ----
docker rm -f consul-server consul-client >/dev/null 2>&1 || true
docker run -d --name consul-server \
  -p 8500:8500 \
  -p 8600:8600/tcp -p 8600:8600/udp \
  hashicorp/consul:1.19 \
  agent -server -bootstrap-expect=1 -ui -client=0.0.0.0 -dns-port=8600 -node=server-1

# IP del contenedor del server (bridge por defecto)
SERVER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' consul-server)

# ---- Consul CLIENT (se une por IP) ----
docker run -d --name consul-client \
  hashicorp/consul:1.19 \
  agent -retry-join="$SERVER_IP" -client=0.0.0.0 -node=client-1

# Registrar servicio Flask con health check
# Usa la IP privada de la VM definida en Vagrant
HOST_IP="192.168.50.3"

docker exec consul-client sh -c "cat > /consul/config/flask.json <<EOF
{
  \"services\": [
    {
      \"name\": \"flask-example\",
      \"tags\": [\"python\"],
      \"address\": \"$HOST_IP\",
      \"port\": 5000,
      \"checks\": [
        { \"http\": \"http://$HOST_IP:5000/health\", \"interval\": \"10s\", \"timeout\": \"5s\" }
      ]
    }
  ]
}
EOF"

# Recarga en memoria para que lea flask.json
docker kill -s HUP consul-client

# Permisos de la carpeta para vagrant
chown -R vagrant:vagrant /home/vagrant/test_docker3

