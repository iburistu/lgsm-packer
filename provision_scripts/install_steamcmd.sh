#! /bin/bash -e

sudo dpkg --add-architecture i386
sudo apt update
echo steam steam/license note '' | debconf-set-selections
echo steam steam/question select 'I AGREE' | debconf-set-selections
sudo apt-get install --yes --install-recommends steamcmd
