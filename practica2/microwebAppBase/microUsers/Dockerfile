# microUsers/Dockerfile
FROM python:3.11-slim

# Paquetes para MariaDB y compilar mysqlclient si se usa
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server mariadb-client \
    build-essential default-libmysqlclient-dev \
  && rm -rf /var/lib/apt/lists/*

# MariaDB corre como usuario mysql
RUN usermod -d /var/lib/mysql mysql && mkdir -p /var/lib/mysql /run/mysqld \
  && chown -R mysql:mysql /var/lib/mysql /run/mysqld

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copia app e init.sql
COPY . /app
# Copia init al directorio estándar
RUN mkdir -p /docker-entrypoint-initdb.d
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# Entrypoint que arranca MariaDB y luego la app
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5002
CMD ["/entrypoint.sh"]

