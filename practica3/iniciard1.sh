#!/bin/bash

cd test_docker1

sudo docker build -t centos .

sudo docker run -dp 8080:80 centos
