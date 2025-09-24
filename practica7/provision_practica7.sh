#!/bin/bash
#
echo "Iniciar cluster"

# Agregar usuario vagrant al grupo docker y ejecutar minikube como vagrant
usermod -aG docker vagrant
sudo -u vagrant minikube start

echo "Instalar pod de hello-minikube"

if ! sudo -u vagrant kubectl get deployment hello-minikube &> /dev/null; then
    sudo -u vagrant kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
else
    echo "Deployment 'hello-minikube' ya existe"
fi

echo "Crear un servicio"

if ! sudo -u vagrant kubectl get service hello-minikube &> /dev/null; then
    sudo -u vagrant kubectl expose deployment hello-minikube --type=NodePort --port=8080
else
    echo "Service 'hello-minikube' ya existe"
fi


####################################
#Dockerfile + server.js
#
#
sudo -u vagrant bash -c 'eval $(minikube docker-env)'

cd /home/vagrant/hello-node

echo "Construir imagen"
sudo -u vagrant bash -c 'eval $(minikube docker-env) && docker build -t hello-node:v1 .'

echo "Desplegar el pod hello-node"
if ! sudo -u vagrant kubectl get deployment hello-node &> /dev/null; then
    sudo -u vagrant kubectl create deployment hello-node --image=hello-node:v1 --port=8080
else
    echo "Deployment 'hello-node' ya existe"
fi

echo "Generar servicio"
if ! sudo -u vagrant kubectl get service hello-node &> /dev/null; then
    sudo -u vagrant kubectl expose deployment hello-node --type=NodePort
else
    echo "Service 'hello-node' ya existe"
fi

echo "Escalar la aplicacion a 4 replicas"
sudo -u vagrant kubectl scale deployments/hello-node --replicas=4

echo "Reducir a dos replicas"
sudo -u vagrant kubectl scale deployments/hello-node --replicas=2



