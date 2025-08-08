#!/bin/bash

#Iniciar Microservicios
echo "Iniciando microservicios..."

echo "Iniciando microservicio de usuarios..."
cd /home/vagrant/microUsers
export FLASK_APP=run.py
nohup /usr/local/bin/flask run --host=0.0.0.0 --port 5002 > microusers.log 2>&1 &
echo "MicroUsers iniciado en puerto 5002 (PID: $!)"

echo "Iniciando microservicio de productos..."
cd /home/vagrant/microProducts
export FLASK_APP=run.py
nohup /usr/local/bin/flask run --host=0.0.0.0 --port 5003 > microproducts.log 2>&1 &
echo "MicroProducts iniciado en puerto 5003 (PID: $!)"

echo "Iniciando microservicio de frontend..."
cd /home/vagrant/frontend
export FLASK_APP=run.py
nohup /usr/local/bin/flask run --host=0.0.0.0 --port 5001 > frontend.log 2>&1 &
echo "Frontend iniciado en puerto 5001 (PID: $!)"

echo "Todos los microservicios han sido iniciados!"
echo "Logs disponibles en:"
echo "  - /home/vagrant/microUsers/microusers.log"
echo "  - /home/vagrant/microProducts/microproducts.log" 
echo "  - /home/vagrant/frontend/frontend.log"