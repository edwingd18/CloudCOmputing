#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

if ! command -v ftp >/dev/null 2>&1; then
  apt-get update
  apt-get install -y inetutils-ftp
fi
# Opcionales:
# apt-get install -y lftp openssh-client

