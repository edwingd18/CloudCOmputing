#!/bin/bash

cd test_docker1

sudo docker build -t ejemplo1 .

sudo docker run -dp 8080:80 ejemplo1
