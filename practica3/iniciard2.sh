#!/bin/bash

cd test_docker2

sudo docker build -t ejemplo2 .

sudo docker run -dp 8081:80 ejemplo2
