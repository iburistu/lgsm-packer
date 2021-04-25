#!/bin/bash -e

cd ~

wget -O linuxgsm.sh https://linuxgsm.sh
chmod +x linuxgsm.sh
bash linuxgsm.sh arkserver 

./arkserver ai

(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/arkserver  monitor > /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "*/30 * * * * /home/ubuntu/arkserver  update > /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "0 0 * * 0 /home/ubuntu/arkserver  update-lgsm > /dev/null 2>&1") | crontab -