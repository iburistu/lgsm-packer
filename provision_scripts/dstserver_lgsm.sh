#!/bin/bash -e

cd ~

wget -O linuxgsm.sh https://linuxgsm.sh
chmod +x linuxgsm.sh
bash linuxgsm.sh dstserver
bash linuxgsm.sh dstserver

mv dstserver dstserver-1

mkdir -p lgsm/config-lgsm/dstserver-1
printf "## Predefined Parameters\nsharding=\"true\"\nmaster=\"true\"\nshard=\"Master\"\ncluster=\"Cluster_1\"\ncave=\"false\"" > lgsm/config-lgsm/dstserver-1/instance.cfg

mkdir -p .klei/DoNotStarveTogether/Cluster_1/Master
printf "[NETWORK]\nserver_port = 11000\n\n[STEAM]\nauthentication_port = 8768\nmaster_server_port = 27018" > .klei/DoNotStarveTogether/Cluster_1/Master/server.ini

mkdir -p lgsm/config-lgsm/dstserver-2
printf "## Predefined Parameters\nsharding=\"true\"\nmaster=\"false\"\nshard=\"Caves\"\ncluster=\"Cluster_1\"\ncave=\"true\"" > lgsm/config-lgsm/dstserver-2/instance.cfg

mkdir -p .klei/DoNotStarveTogether/Cluster_1/Caves
printf "[NETWORK]\nserver_port = 11000\n\n[STEAM]\nauthentication_port = 8768\nmaster_server_port = 27019" > .klei/DoNotStarveTogether/Cluster_1/Caves/server.ini

printf "[SHARD]\nshard_enabled = true" > .klei/DoNotStarveTogether/Cluster_1/cluster.ini

./dstserver-1 ai
./dstserver-2 ai

# You'll need to generate and add an authentication token to run your server
# You can find instructions here: https://docs.linuxgsm.com/game-servers/dont-starve-together#authentication-token

(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/dstserver-1 monitor > /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "*/30 * * * * /home/ubuntu/dstserver-1 update > /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "0 0 * * 0 /home/ubuntu/dstserver-1 update-lgsm > /dev/null 2>&1") | crontab -

(crontab -l 2>/dev/null; echo "*/5 * * * * /home/ubuntu/dstserver-2 monitor > /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "*/30 * * * * /home/ubuntu/dstserver-2 update > /dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "0 0 * * 0 /home/ubuntu/dstserver-2 update-lgsm > /dev/null 2>&1") | crontab -