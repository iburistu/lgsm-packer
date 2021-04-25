#!/bin/bash -e

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y sudo tzdata curl cron iproute2
rm -rf /var/lib/apt/lists/*
adduser --disabled-password --gecos '' ubuntu
adduser ubuntu sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers