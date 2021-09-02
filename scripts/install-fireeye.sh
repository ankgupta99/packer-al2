#!/bin/bash
set -x
###Copy Fireeye agent from s3####
aws s3 cp s3://maf-sources/xagt-29.7.0-1.el7.x86_64.rpm .
aws s3 cp s3://maf-sources/agent_config.json .
###Install Fireeye###
sudo rpm -Uvh xagt-29.7.0-1.el7.x86_64.rpm
sudo /opt/fireeye/bin/xagt -i agent_config.json
sudo systemctl start xagt
systemctl status xagt
systemctl show -p ActiveState xagt