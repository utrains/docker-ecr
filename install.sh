# docker install
sudo yum update -y
sudo yum install docker
sudo groupadd docker
sudo usermod -aG docker $USER
sudo service docker start