#!/bin/bash -e

curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -
sudo apt install -y nodejs
npm install gamedig -g