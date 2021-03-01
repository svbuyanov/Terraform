#!/bin/bash
update-grub2
apt update
apt full-upgrade -qq -y
apt install python3-pip -y -qq
pip3 install --upgrade awscli
apt install python-boto python-boto3 python-botocore python3-boto python3-boto3 python3-botocore -qq -y
mkdir /tmp/ssm
cd /tmp/ssm
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb
sudo systemctl enable amazon-ssm-agent