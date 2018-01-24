# Hyperledger Fabric - Banking Usecase

This sub-projects is a PoC of a Banking Usecase using Hyperledger Fabric.

## Requisites

This is the list of requisites in order to run this PoC:

1. Docker and Docker Compose
2. Go
3. NodeJS
4. Hyperledger Fabric Bootstrap Tools

## Instructions for installing the requirements in Ubuntu 16.04

### Install Docker

```
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce docker-compose

sudo groupadd docker
sudo usermod -aG docker $USER

exit
```

### Fix Docker Daemon config

```
sudo sh -c 'echo "{
  \"exec-opts\": [\"native.cgroupdriver=systemd\"]
}" > /etc/docker/daemon.json'
sudo chmod a+r /etc/docker/daemon.json

sudo systemctl daemon-reload
sudo systemctl start docker.service
```

### Install Go

```
sudo add-apt-repository ppa:gophers/archive
sudo apt update
sudo apt-get install golang-1.7-go
```

### Install Node

```
curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh && chmod u+x nodesource_setup.sh && sudo ./nodesource_setup.sh
sudo apt-get install nodejs
```

### Install Hyperledger Fabric fabric-shim

```
npm install fabric-shim
```

### Launch Hyperledger Fabric bootstrap script

```
sudo apt install libtool libltdl-dev

mkdir fabric-tools
cd fabric-tools

VERSION=1.0.5
curl -sSL https://goo.gl/6wtTN5 | bash -s $VERSION $VERSION

echo "export PATH=$PWD/bin:$PATH" >> $HOME/.bashrc
```

## Running the PoC

### Launching the Hyperledger Fabric Cluster 

```
./fnm.sh -m up
```

### Stopping the Hyperledger Fabric Cluster 

```
./fnm.sh -m down
```