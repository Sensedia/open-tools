#! /bin/bash
# Install Docker
sudo curl -fsSL https://get.docker.com -o get-docker.sh;
sudo sh get-docker.sh;
sudo usermod -aG docker ubuntu;

# Install Docker Compose
COMPOSE_VERSION=1.29.2
sudo curl -L https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose
sudo chmod 777 /usr/bin/docker-compose

# Prepare Docker workspace
sudo mkdir /docker

# Install Git
sudo apt update -y
sudo apt install -y git

# Install Node Exporter
curl -sSL https://cloudesire.github.io/node-exporter-installer/install.sh | sudo sh

# Install cAdvisor
docker run -d --restart=always \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8088:8080 \
  --detach=true \
  --name=cadvisor \
  gcr.io/google-containers/cadvisor:latest
