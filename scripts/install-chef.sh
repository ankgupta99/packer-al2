#!/bin/bash
set -x
mkdir chef_install
aws s3 cp s3://maf-sources/chef-17.4.38-1.el7.x86_64.rpm ./chef_install
sudo rpm -ivh  chef_install/chef-17.4.38-1.el7.x86_64.rpm 
rm -rf chef_install

