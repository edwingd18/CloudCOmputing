terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

variable "host_ip" {
  default = "192.168.50.1"
}

variable "host_user" {
  default = "edwin"
}

locals {
  vm2_path = "/home/${var.host_user}/vm2"
}

# 1. CREAR VAGRANTFILE
resource "local_file" "vm2_vagrantfile" {
  filename = "${path.module}/vm2/Vagrantfile"
  content  = <<-EOF
    Vagrant.configure("2") do |config|
      config.vm.box = "ubuntu/focal64"
      config.vm.hostname = "vm2-desde-terraform"
      
      config.vm.provider "virtualbox" do |vb|
        vb.name = "vm2-creada-desde-vm1"
        vb.memory = "1024"
        vb.cpus = 1
      end
      
      config.vm.network "private_network", ip: "192.168.50.20"
      config.vm.network "forwarded_port", guest: 80, host: 8081
      config.vm.network "forwarded_port", guest: 22, host: 2223, id: "ssh"
      
      config.vm.provision "shell", inline: <<-SHELL
        apt-get update
        echo "VM2 lista"
      SHELL
    end
  EOF
}

# 2. COPIAR AL HOST
resource "null_resource" "copy_to_host" {
  depends_on = [local_file.vm2_vagrantfile]
  
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -r ${path.module}/vm2 ${var.host_user}@${var.host_ip}:/home/${var.host_user}/"
  }
}

# 3. CREAR VM2
resource "null_resource" "vm2_lifecycle" {
  depends_on = [null_resource.copy_to_host]
  
  triggers = {
    vagrantfile = local_file.vm2_vagrantfile.content
    host_user = var.host_user
    host_ip = var.host_ip
    vm2_path = local.vm2_path
  }
  
  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no ${var.host_user}@${var.host_ip} 'cd ${local.vm2_path} && vagrant destroy -f && vagrant up'"
  }
  
  provisioner "local-exec" {
    when = destroy
    command = "ssh -o StrictHostKeyChecking=no ${self.triggers.host_user}@${self.triggers.host_ip} 'cd ${self.triggers.vm2_path} && vagrant destroy -f' || true"
  }
}

# 4. ESPERAR Y VERIFICAR CONECTIVIDAD
resource "null_resource" "wait_and_verify" {
  depends_on = [null_resource.vm2_lifecycle]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Esperando a que VM2 esté lista..."
      sleep 40
      
      echo "Verificando conectividad..."
      for i in {1..30}; do
        if ping -c 1 -W 2 192.168.50.20 > /dev/null 2>&1; then
          echo "VM2 alcanzable por ping"
          
          # Verificar SSH
          if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 vagrant@192.168.50.20 'echo OK' 2>/dev/null; then
            echo "VM2 alcanzable por SSH - Lista para Ansible"
            exit 0
          fi
        fi
        echo "Intento $i/30 - esperando..."
        sleep 2
      done
      
      echo "ADVERTENCIA: VM2 no responde completamente, pero continuando..."
      exit 0
    EOT
  }
}

# 5. CONFIGURAR APACHE CON ANSIBLE (ÚLTIMO PASO)
resource "null_resource" "configure_apache" {
  depends_on = [null_resource.wait_and_verify]
  
  provisioner "local-exec" {
    command = "cd /home/vagrant/ansible && ansible-playbook -i inventory.ini apache_setup.yml"
    working_dir = "/home/vagrant"
  }
}

output "resumen" {
  value = <<-EOT
    ========================================
    VM1: 192.168.50.10
    VM2: 192.168.50.20
    
    Apache: http://localhost:8081
    
    NOTA: Si Ansible falla, ejecuta manualmente:
    vagrant ssh -c "cd /home/vagrant/ansible && ansible-playbook -i inventory.ini apache_setup.yml"
    ========================================
  EOT
}
