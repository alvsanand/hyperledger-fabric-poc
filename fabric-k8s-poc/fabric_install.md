# HyperLedger Fabric Installation Manual

This manual explains how to install a HyperLedger Fabric in Kubernetes cluster

## Requisites

This is the list of requisites in order to run this PoC:

1. Kubernetes Cluster
2. NFS server
3. Hyperledger Tools

## Installing Hyperledger Tools

### Pre-requisites

```
curl -O https://hyperledger.github.io/composer/prereqs-ubuntu.sh && \
    chmod u+x prereqs-ubuntu.sh && \
    ./prereqs-ubuntu.sh
```

### Installing Hyperledger Composer development tools

```
npm install -g composer-cli
npm install -g generator-hyperledger-composer
npm install -g composer-rest-server
npm install -g yo
npm install -g composer-playground
```

### Installing Hyperledger fabric-tools

```
mkdir ~/fabric-tools && cd ~/fabric-tools
curl -O https://raw.githubusercontent.com/hyperledger/composer-tools/master/packages/fabric-dev-servers/fabric-dev-servers.tar.gz

tar xvzf fabric-dev-servers.tar.gz
```

### Installing Hyperledger Platform-specific Binaries

```
curl https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-${VERSION}/hyperledger-fabric-linux-amd64-1.0.5.tar.gz | tar xz -C ~/fabric-tools
```

## Generating config

```
cd fabric_install

./init.sh
```

## Starting Hyperledger Fabric Cluster

```
./start.sh
```

## Delete Hyperledger Fabric Cluster

```
rm -Rf channel-artifacts
rm -Rf crypto-config

kubectl delete --all replicaset --grace-period=0 --force --namespace=partnersbank
kubectl delete --all replicaset --namespace=multibankwest
kubectl delete --all replicaset --namespace=orgorderer1

kubectl delete --grace-period=0 --force namespace partnersbank
kubectl delete --grace-period=0 --force namespace multibankwest
kubectl delete --grace-period=0 --force namespace orgorderer1

kubectl delete --grace-period=0 --force persistentvolumes partnersbank-artifacts-pv
kubectl delete --grace-period=0 --force persistentvolumes partnersbank-pv
kubectl delete --grace-period=0 --force persistentvolumes multibankwest-artifacts-pv
kubectl delete --grace-period=0 --force persistentvolumes multibankwest-pv
kubectl delete --grace-period=0 --force persistentvolumes orgorderer1-pv
```