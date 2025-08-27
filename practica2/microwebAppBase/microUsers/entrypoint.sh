#!/usr/bin/env bash
set -euo pipefail

# Inicializa MariaDB si no existe
if [ ! -d "/var/lib/mysql/mysql" ]; then
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Arranca MariaDB en background
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking=0 --bind-address=127.0.0.1 &
MYSQL_PID=$!

# Espera a que el socket/puerto esté listo
echo "Esperando a MariaDB (users)..."
for i in {1..60}; do
  if mariadb -h 127.0.0.1 -uroot -e "SELECT 1" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Aplica el init.sql (idempotente: crea base y tablas si no existen)
if [ -f "/docker-entrypoint-initdb.d/init.sql" ]; then
  mariadb -h 127.0.0.1 -uroot < /docker-entrypoint-initdb.d/init.sql || true
fi

echo "Iniciando microUsers..."
exec python run.py

