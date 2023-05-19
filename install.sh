#!/bin/bash
# docker install
sudo yum update -y
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo service docker start

#install git
sudo yum install git -y
# install wget
sudo yum install wget -y
