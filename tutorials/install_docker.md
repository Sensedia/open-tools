<!-- TOC -->

- [Install Docker](#install-docker)

<!-- TOC -->

# Install Docker

Install Docker CE (Community Edition) following the instructions of the pages below, according to your GNU/Linux distribution.

* CentOS: https://docs.docker.com/install/linux/docker-ce/centos/
* Debian: https://docs.docker.com/install/linux/docker-ce/debian/
* Ubuntu: https://docs.docker.com/install/linux/docker-ce/ubuntu/

Start the ``docker`` service, configure Docker to boot up with the OS and add your user to the ``docker`` group.

```bash
# Start the Docker service
sudo systemctl start docker

# Configure Docker to boot up with the OS
sudo systemctl enable docker

# Add your user to the Docker group
sudo usermod -aG docker $USER
sudo setfacl -m user:$USER:rw /var/run/docker.sock
```

Source: https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot