# Rolling Updates en Kubernetes - Demostración

## ¿Qué son los Rolling Updates?

Los **Rolling Updates** permiten actualizar aplicaciones sin tiempo de inactividad, reemplazando gradualmente las instancias antiguas con nuevas.

### Características principales:
- **Zero Downtime**: No hay interrupción del servicio
- **Gradual**: Se actualiza pod por pod
- **Reversible**: Se puede hacer rollback fácilmente
- **Configurable**: Control sobre velocidad y disponibilidad

## Configuración de la Estrategia

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1    # Máximo pods no disponibles
    maxSurge: 1         # Máximo pods adicionales
```

## Demostración

### 1. Ejecutar la demo
```bash
vagrant ssh servidorUbuntu
cd /home/vagrant
chmod +x /vagrant/rolling-demo.sh
/vagrant/rolling-demo.sh
```

### 2. Comandos clave para monitorear

**Ver el estado del rollout:**
```bash
kubectl rollout status deployment/rolling-app --watch
```

**Ver pods en tiempo real:**
```bash
watch kubectl get pods -l app=rolling-app
```

**Probar la aplicación durante el update:**
```bash
# En una terminal separada
while true; do curl -s http://$(minikube ip):30080 | jq -r '.version'; sleep 1; done
```

### 3. Comandos de control

**Pausar el rollout:**
```bash
kubectl rollout pause deployment/rolling-app
```

**Reanudar el rollout:**
```bash
kubectl rollout resume deployment/rolling-app
```

**Hacer rollback:**
```bash
kubectl rollout undo deployment/rolling-app
```

**Rollback a versión específica:**
```bash
kubectl rollout undo deployment/rolling-app --to-revision=1
```

### 4. Verificar historial
```bash
kubectl rollout history deployment/rolling-app
```

## Lo que observarás

1. **Fase inicial**: 4 pods con versión v1
2. **Durante update**: Mezcla de pods v1 y v2
3. **Fase final**: 4 pods con versión v2
4. **Sin downtime**: El servicio responde siempre

## Parámetros importantes

- **maxUnavailable**: Controla cuántos pods pueden estar no disponibles
- **maxSurge**: Controla cuántos pods adicionales se pueden crear
- **readinessProbe**: Kubernetes espera que el pod esté listo antes de continuar
- **livenessProbe**: Verifica que el pod esté funcionando correctamente

## Casos de uso

- Despliegue de nuevas funcionalidades
- Actualizaciones de seguridad
- Cambios de configuración
- Escalado de recursos