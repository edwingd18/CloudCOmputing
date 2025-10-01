# MicroProyecto2 - Cloud Computing

Este proyecto implementa diferentes soluciones de infraestructura como código y orquestación de contenedores utilizando Vagrant, Terraform, Ansible y Kubernetes.

## 📁 Estructura del Proyecto

### Punto 1: Automatización de VMs con Vagrant, Terraform y Ansible

**Objetivo:** Crear y configurar automáticamente dos máquinas virtuales donde VM1 aprovisiona a VM2.

**Componentes:**
- **Vagrant:** Crea VM1 (control-node) con Ubuntu 20.04, Terraform y Ansible preinstalados
- **Terraform:** Desde VM1, genera un Vagrantfile para VM2, lo copia al host físico y ejecuta la creación de VM2
- **Ansible:** Configura Apache en VM2 con una página web personalizada

**Características:**
- VM1: 192.168.50.10 (2GB RAM, 2 CPUs)
- VM2: 192.168.50.20 (1GB RAM, 1 CPU)
- Apache accesible en: http://localhost:8081
- Página web con diseño degradado personalizado

**Archivos principales:**
- `punto1/Vagrantfile` - Configuración de VM1
- `punto1/terraform/main.tf` - Infraestructura de VM2
- `punto1/ansible/apache_setup.yml` - Playbook de configuración de Apache
- `punto1/ansible/inventory.ini` - Inventario de hosts

**Uso:**
```bash
cd punto1
vagrant up
vagrant ssh
cd terraform
terraform init
terraform apply -auto-approve
```

---

### Punto 2: Despliegue de Home Assistant en Kubernetes

**Objetivo:** Desplegar la aplicación Home Assistant en un clúster de Kubernetes.

**Componentes:**
- Deployment de Home Assistant con imagen oficial
- Service tipo LoadBalancer para acceso externo
- Puerto 8123 para la interfaz web

**Características:**
- 1 réplica de Home Assistant
- Imagen: `ghcr.io/home-assistant/home-assistant:stable`
- Expone servicio en puerto 8123

**Archivos principales:**
- `punto2/homeassistant.yaml` - Deployment y Service de Kubernetes

**Uso:**
```bash
kubectl apply -f punto2/homeassistant.yaml
kubectl get services
# Acceder a la IP externa en el puerto 8123
```

---

### Punto 3: Clúster AKS en Azure con Terraform

**Objetivo:** Crear un clúster de Azure Kubernetes Service (AKS) y desplegar Home Assistant automáticamente.

**Componentes:**
- Resource Group en Azure
- Clúster AKS con configuración optimizada
- Deployment de Home Assistant (3 réplicas)
- Service LoadBalancer con IP pública

**Características:**
- Tier: Free
- Pool de nodos configurable
- Identity: SystemAssigned
- Home Assistant con 3 réplicas
- Límites de recursos: 512Mi RAM, 500m CPU
- LoadBalancer con IP pública de Azure

**Archivos principales:**
- `punto3/terraform-aks/main.tf` - Resource Group y Cluster AKS
- `punto3/terraform-aks/kubernetes.tf` - Deployment y Service de Home Assistant
- `punto3/terraform-aks/provider.tf` - Configuración de providers
- `punto3/terraform-aks/variables.tf` - Variables configurables
- `punto3/terraform-aks/outputs.tf` - Outputs del cluster

**Uso:**
```bash
cd punto3/terraform-aks
terraform init
terraform apply
# Obtener credenciales del cluster
az aks get-credentials --resource-group <nombre> --name <cluster>
kubectl get services
```

---

## 🛠️ Tecnologías Utilizadas

- **Vagrant:** Gestión de máquinas virtuales
- **Terraform:** Infraestructura como código
- **Ansible:** Automatización de configuración
- **Kubernetes:** Orquestación de contenedores
- **Azure AKS:** Kubernetes administrado en la nube
- **VirtualBox:** Hipervisor para VMs locales
- **Apache:** Servidor web
- **Home Assistant:** Plataforma de automatización del hogar

---

## 📋 Requisitos

- VirtualBox
- Vagrant
- Terraform >= 1.6.0
- Ansible
- kubectl
- Azure CLI (para punto 3)
- Cuenta de Azure activa (para punto 3)

---

## 🚀 Inicio Rápido

Cada punto es independiente y puede ejecutarse por separado siguiendo las instrucciones específicas de cada sección.

**Punto 1:** Requiere configuración de red host-only en VirtualBox
**Punto 2:** Requiere un clúster de Kubernetes existente
**Punto 3:** Requiere credenciales de Azure configuradas
