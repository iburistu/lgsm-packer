#!/bin/bash -e

cd ~

wget -O linuxgsm.sh https://linuxgsm.sh
chmod +x linuxgsm.sh
bash linuxgsm.sh terrariaserver

mkdir -p lgsm/config-lgsm/terrariaserver
touch lgsm/config-lgsm/terrariaserver/common.cfg

# If you don't have Steam Guard enabled on the account you want to use, you can write steamuser= & steampass= to common.cfg
# If you do have Steam Guard (and you should!), you'll have to install the server manually once you SSH in
# Add your creds to common.cfg and run ./terrariaserver install

(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/terrariaserver monitor > /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "*/30 * * * * /home/ubuntu/terrariaserver update > /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "0 0 * * 0 /home/ubuntu/terrariaserver update-lgsm > /dev/null 2>&1") | crontab -