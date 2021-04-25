#!/bin/bash -e

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
# Docker gets big mad about `source ~/.bashrc` so I use this instead
source $HOME/.nvm/nvm.sh
nvm install lts/fermium
nvm use lts/fermium
npm install gamedig -g