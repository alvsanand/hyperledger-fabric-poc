# Kubernetes Installation Manual

This manual explains how to install a local Kubernetes cluster in Ubuntu 16.04

## Install Docker

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
sudo apt-get install docker-ce

sudo groupadd docker
sudo usermod -aG docker $USER

sudo sh -c "echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}' > /etc/docker/daemon.json"
sudo chmod a+r /etc/docker/daemon.json
```

## Installing kubeadm, kubelet and kubectl

```
sudo apt-get update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list" 
sudo chmod a+r /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
```

## Disable Swap partitions

```
sudo swapoff -a
sudo sed -i -E '/^.*swap.*$/d' /etc/fstab
```

## Initializing K8s cluster

```
sudo kubeadm init

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Installing Pod Network

```
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Installing Kubernetes Dashboard

```
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

kubectl taint nodes --all node-role.kubernetes.io/master-
```

## Creating Admin token for Dashboard (not in Production)

```
echo "apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
" > dashboard-admin.yaml

kubectl -n kube-system get secret | grep kubernetes-dashboard-token | awk -F" " '{print $1}' | xargs kubectl -n kube-system describe secret | grep "token:" | awk -F" " '{print $2}'
```

## Accesing Dashboard

* Execute:
```
kubectl proxy
```

* Go to [Kubernetes Dashboard](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default) and enter precious token.

