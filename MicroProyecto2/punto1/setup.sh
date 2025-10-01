#!/bin/bash
#
set -e

echo "=== Script de automatización completa ==="

# 1. Destruir todo
echo "1. Limpiando ambiente..."
vagrant destroy -f 2>/dev/null || true
rm -rf ~/vm2


# 2. Crear VM1
echo "2. Creando VM1..."
vagrant up


# 3. Configurar SSH VM1 → HOST
echo "3. Configurando SSH (VM1 → HOST)..."
vagrant ssh -c "cat /home/vagrant/.ssh/id_rsa.pub" >> ~/.ssh/authorized_keys


# 4. Limpiar estado Terraform
echo "4. Limpiando estado de Terraform..."
vagrant ssh -c "cd terraform && rm -rf terraform.tfstate*" 2>/dev/null || true


# 5. Crear VM2
echo "5. Creando VM2 con Terraform..."
vagrant ssh -c "cd terraform && terraform init && terraform apply -auto-approve" || true


# 6. Esperar a que VM2 esté lista
echo "6. Esperando a que VM2 esté completamente lista..."
sleep 10
