#!/bin/bash

echo "=== DEMOSTRACIÓN DE ROLLING UPDATES EN KUBERNETES ==="
echo ""

echo "1. Construir imágenes Docker"
echo "================================"
cd /home/vagrant/rolling-app

# Construir imagen v1
echo "Construyendo imagen v1..."
eval $(minikube docker-env)
docker build -f Dockerfile-v1 -t rolling-app:v1 .

echo ""
echo "2. Desplegar versión inicial (v1)"
echo "================================="
kubectl apply -f deployment.yaml

echo "Esperando que el deployment esté listo..."
kubectl rollout status deployment/rolling-app

echo ""
echo "3. Verificar pods iniciales"
echo "==========================="
kubectl get pods -l app=rolling-app

echo ""
echo "4. Probar la aplicación v1"
echo "=========================="
NODE_PORT=$(kubectl get service rolling-app-service -o jsonpath='{.spec.ports[0].nodePort}')
MINIKUBE_IP=$(minikube ip)
echo "URL: http://$MINIKUBE_IP:$NODE_PORT"
curl -s http://$MINIKUBE_IP:$NODE_PORT | jq .

echo ""
echo "5. Construir imagen v2"
echo "======================"
docker build -f Dockerfile-v2 -t rolling-app:v2 .

echo ""
echo "6. INICIAR ROLLING UPDATE a v2"
echo "==============================="
echo "Comando: kubectl set image deployment/rolling-app rolling-app=rolling-app:v2"
kubectl set image deployment/rolling-app rolling-app=rolling-app:v2

echo ""
echo "7. Monitorear el Rolling Update"
echo "==============================="
echo "Estado del rollout:"
kubectl rollout status deployment/rolling-app

echo ""
echo "8. Verificar pods durante/después del update"
echo "============================================="
kubectl get pods -l app=rolling-app

echo ""
echo "9. Probar la aplicación v2"
echo "=========================="
curl -s http://$MINIKUBE_IP:$NODE_PORT | jq .

echo ""
echo "10. Historial de rollouts"
echo "========================="
kubectl rollout history deployment/rolling-app

echo ""
echo "=== COMANDOS ADICIONALES PARA DEMOSTRACIÓN ==="
echo "- Ver rollout en tiempo real: kubectl rollout status deployment/rolling-app --watch"
echo "- Pausar rollout: kubectl rollout pause deployment/rolling-app"
echo "- Reanudar rollout: kubectl rollout resume deployment/rolling-app"
echo "- Rollback: kubectl rollout undo deployment/rolling-app"
echo "- Rollback a versión específica: kubectl rollout undo deployment/rolling-app --to-revision=1"