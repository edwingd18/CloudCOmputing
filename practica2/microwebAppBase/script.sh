#!/bin/bash

# Install MySQL
echo "Installing MySQL"

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

sudo apt update
sudo apt install mysql-server -y
sudo systemctl start mysql.service

#Create and fill Database
echo "Creating and filling database"
sudo mysql -h localhost -u root -proot < /home/vagrant/init_users.sql
sudo mysql -h localhost -u root -proot < /home/vagrant/init_products.sql

#Adding permissions to remote access
echo "Adding permissions to remote access"
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql.service

# Install Python Flask, Flask-MySQLdb and nohup
sudo apt install python3-dev default-libmysqlclient-dev build-essential pkg-config mysql-client python3-pip coreutils -y
pip3 install Flask==2.3.3
pip3 install flask-cors
pip3 install Flask-MySQLdb
pip install Flask-SQLAlchemy

# Install Consul
echo "Installing Consul"
cd /tmp
wget https://releases.hashicorp.com/consul/1.15.3/consul_1.15.3_linux_amd64.zip
sudo apt install unzip -y
unzip consul_1.15.3_linux_amd64.zip
sudo mv consul /usr/local/bin/
sudo mkdir -p /opt/consul
sudo mkdir -p /etc/consul.d
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo chown -R consul:consul /opt/consul /etc/consul.d
sudo chmod -R 755 /opt/consul /etc/consul.d

# Install Python Consul client
pip3 install flask-consulate

# Configure Consul
echo "Configuring Consul"
sudo cp /home/vagrant/consul.json /etc/consul.d/consul.json
sudo cp /home/vagrant/consul.service /etc/systemd/system/consul.service
sudo chown consul:consul /etc/consul.d/consul.json
sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul

echo "Consul setup complete!"
echo "Consul UI available at: http://192.168.50.4:8500"

sudo chmod +x /home/vagrant/iniciar_microservicios.sh
echo "Microservices script is now executable."
