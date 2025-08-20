#!/bin/bash

sudo docker run -d --name galeria \
  -dp 8083:80 \
  -v /home/vagrant/vol_docker/docker_imgs:/usr/share/nginx/html/images \
  nginx
