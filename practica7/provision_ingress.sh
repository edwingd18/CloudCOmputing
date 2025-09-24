#!/bin/bash
#
echo "Activar el ingress controller"
sudo -u vagrant minikube addons enable ingress

echo "Esperando que el ingress controller esté listo..."
sudo -u vagrant kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s

echo "Crear un despliegue"
# Solo crear si no existe
if ! sudo -u vagrant kubectl get deployment web &> /dev/null; then
    sudo -u vagrant kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
else
    echo "Deployment 'web' ya existe"
fi

if ! sudo -u vagrant kubectl get deployment web2 &> /dev/null; then
    sudo -u vagrant kubectl create deployment web2 --image=gcr.io/google-samples/hello-app:2.0
else
    echo "Deployment 'web2' ya existe"
fi

echo "Crear un servicio"
# Solo crear servicios si no existen
if ! sudo -u vagrant kubectl get service web &> /dev/null; then
    sudo -u vagrant kubectl expose deployment web --type=NodePort --port=8080
else
    echo "Service 'web' ya existe"
fi

if ! sudo -u vagrant kubectl get service web2 &> /dev/null; then
    sudo -u vagrant kubectl expose deployment web2 --port=8080 --type=NodePort
else
    echo "Service 'web2' ya existe"
fi

echo "Crear un manifiesto"
sudo -u vagrant kubectl apply -f https://kubernetes.io/examples/service/networking/example-ingress.yaml





