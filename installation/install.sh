#!/bin/bash
# docker install
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -aG docker ec2-user
newgrp docker
sudo service docker restart
sudo systemctl enable docker 
# Change terminal color for user ec2-user
echo "PS1='\e[1;32m\u@\h \w$ \e[m'" >> /home/ec2-user/.bash_profile
#install git
sudo yum install git -y
# install wget
sudo yum install wget -y

#install docker compose
sudo curl -L https://github.com/docker/compose/releases/download/1.20.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

git clone https://github.com/utrains/static-app.git
cd static-app
docker build -t webapp .
aws ecr get-login-password --region $1 | docker login --username AWS --password-stdin $2
docker tag webapp $2
docker push $2
exit 0


