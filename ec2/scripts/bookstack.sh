#!/bin/bash
wget https://raw.githubusercontent.com/BookStackApp/devops/main/scripts/installation-ubuntu-22.04.sh
chmod a+x installation-ubuntu-22.04.sh
IP=`curl ifconfig.me/ip`
sudo ./installation-ubuntu-22.04.sh $IP

# - Default login email: admin@admin.com
# - Default login password: password
