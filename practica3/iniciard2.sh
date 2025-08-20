#!/bin/bash

cd test_docker2

sudo docker build -t voldocker .

sudo docker run -dp 8081:80 voldocker

chmod +x /home/vagrant/vol_docker/script.sh


