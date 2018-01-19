# Hyperledger Fabric - Kubernetes Installation

This manuals explains how to install Hyperledger Fabric in a Kubernetes cluster

## Requisites

This is the list of requisites in order to run this PoC:

1. Kubernetes Cluster
2. NFS server
3. Hyperledger Tools

## Instructions for installing the PoC in Ubuntu 16.04

### Install K8s requisites

See [Kubernetes Installation Manual](k8s_install.md)

### Configure NFS server

```
sudo apt-get install nfs-server

sudo mkdir -p /var/nfs

sudo chown -R nobody:nogroup /var/nfs
sudo chmod -R a+rwx /var/nfs
sudo setfacl -d -m u::rwX,g::rwX,o::rwX /var/nfs

sudo sh -c 'echo "/var/nfs *(rw,no_root_squash,no_subtree_check)" >> /etc/exports'

sudo systemctl restart nfs-server
```

### Installing Hyperledger Tools

See [HyperLedger Fabric Installation Manual](fabric_install.md)