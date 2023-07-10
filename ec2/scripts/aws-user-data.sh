#!/bin/bash
sudo apt update -y
sudo apt upgrade -y
sudo apt install nginx -y
AWS_REGION=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
echo "$AWS_REGION | $INSTANCE_ID" | sudo tee /var/www/html/index.html
