#!/usr/bin/env bash
set -euo pipefail

echo "Configurando DNS en /etc/resolv.conf"
sudo tee /etc/resolv.conf >/dev/null <<'EOF'
nameserver 8.8.8.8
EOF

echo "Instalando vsftpd"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y vsftpd

echo "Habilitando escritura y login de usuarios locales en vsftpd"
# write_enable=YES
sudo sed -ri 's/^#?\s*write_enable\s*=.*/write_enable=YES/' /etc/vsftpd.conf
# local_enable=YES
sudo sed -ri 's/^#?\s*local_enable\s*=.*/local_enable=YES/' /etc/vsftpd.conf
# deshabilitar anónimo
sudo sed -ri 's/^#?\s*anonymous_enable\s*=.*/anonymous_enable=NO/' /etc/vsftpd.conf
# (opcional) encerrar al usuario en su HOME y permitir HOME escribible
grep -q '^chroot_local_user=' /etc/vsftpd.conf || echo 'chroot_local_user=YES' | sudo tee -a /etc/vsftpd.conf >/dev/null
grep -q '^allow_writeable_chroot=' /etc/vsftpd.conf || echo 'allow_writeable_chroot=YES' | sudo tee -a /etc/vsftpd.conf >/dev/null

echo "Creando/seleccionando usuario para FTP"
# Usa 'vagrant' si existe; si no, crea 'ftpuser' con password 'ftpuser'
if id -u vagrant >/dev/null 2>&1; then
  USERNAME="vagrant"
else
  USERNAME="ftpuser"
  sudo useradd -m -s /bin/bash "$USERNAME" || true
  echo "$USERNAME:$USERNAME" | sudo chpasswd
fi

# Carpeta de trabajo
sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/Uploads"
sudo chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/Uploads"

echo "Habilitando y reiniciando vsftpd"
sudo systemctl enable --now vsftpd
sudo systemctl restart vsftpd

echo "Activando ip_forward de forma idempotente"
sudo tee /etc/sysctl.d/99-ip-forwarding.conf >/dev/null <<'EOF'
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system >/dev/null

# (Opcional) abrir puerto 21 si usas UFW
if command -v ufw >/dev/null 2>&1; then
  sudo ufw allow 21/tcp || true
fi

echo "=== RESUMEN ==="
echo "Usuario FTP: $USERNAME"
echo "Password:    $([ "$USERNAME" = "ftpuser" ] && echo ftpuser || echo '(usa la del sistema, p.ej. vagrant)')"
echo "Conéctate con FileZilla: Host=IP_privada_de_la_VM, Port=21, Protocol=FTP, Encryption=Only use plain FTP"

