# hyperledger-fabric-poc
Hyperledger Fabric (Blockchain Framework) Proof of Concept


## Requisites

This is the list of requisites in order to run this PoC:

1. Kubernetes Cluster
2. NFS server
3. Hyperledger Tools

## Instructions for installing the PoC pre-requisites in Ubuntu 16.04

### Install K8s requisites

See [Kubernetes Installation Manual](/Users/avss/work/workspace/hyperledger-fabric-poc/k8s_install/README.md)

### Configure NFS server

```
sudo apt-get install nfs-server

sudo mkdir -p /var/nfs

sudo chown -R nobody:nogroup /var/nfs
sudo chmod -R a+rwx  /var/nfs

sudo sh -c 'echo "/var/nfs *(rw,no_root_squash,no_subtree_check)" >> /etc/exports'

sudo systemctl restart nfs-server
```

### Installing Hyperledger Tools

#### Pre-requisites

```
curl -O https://hyperledger.github.io/composer/prereqs-ubuntu.sh && \
    chmod u+x prereqs-ubuntu.sh && \
    ./prereqs-ubuntu.sh
```

#### Installing Hyperledger Composer development tools

```
npm install -g composer-cli
npm install -g generator-hyperledger-composer
npm install -g composer-rest-server
npm install -g yo
npm install -g composer-playground
```

#### Installing Hyperledger fabric-tools

```
mkdir ~/fabric-tools && cd ~/fabric-tools
curl -O https://raw.githubusercontent.com/hyperledger/composer-tools/master/packages/fabric-dev-servers/fabric-dev-servers.tar.gz

tar xvzf fabric-dev-servers.tar.gz
```

## Running the PoC

## Starting Hyperledger Fabric

```
```