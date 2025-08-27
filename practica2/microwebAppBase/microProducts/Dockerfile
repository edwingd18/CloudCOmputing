# microProducts/Dockerfile
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server mariadb-client \
    build-essential default-libmysqlclient-dev \
  && rm -rf /var/lib/apt/lists/*

RUN usermod -d /var/lib/mysql mysql && mkdir -p /var/lib/mysql /run/mysqld \
  && chown -R mysql:mysql /var/lib/mysql /run/mysqld

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app
RUN mkdir -p /docker-entrypoint-initdb.d
COPY init.sql /docker-entrypoint-initdb.d/init.sql

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5003
CMD ["/entrypoint.sh"]

