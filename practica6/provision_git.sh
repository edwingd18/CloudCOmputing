#!/bin/bash

# Script de aprovisionamiento para haproxy project

echo "=== Iniciando aprovisionamiento del proyecto HAProxy ==="

# Cambiar al directorio home del usuario vagrant
cd /home/vagrant

# Copiar la versión modificada desde /vagrant (synced folder)
if [ -d "/vagrant/haproxy-project" ]; then
    echo "Copiando proyecto modificado con página de error personalizada..."
    cp -r /vagrant/haproxy-project /home/vagrant/haproxy-docker
    sudo chown -R vagrant:vagrant haproxy-docker/
    echo "Proyecto copiado exitosamente"
else
    echo "ERROR: No se encontró el directorio /vagrant/haproxy-project"
fi

echo "=== Aprovisionamiento completado ==="
echo "Proyecto disponible en: /home/vagrant/haproxy-docker/"
