#!/bin/bash
## Download Kubernetes packages 
apt-get update
apt-get install -y curl apt-transport-https ca-certificates wget
curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install kubeadm kubelet kubectl -y
apt-mark hold kubelet kubeadm kubectl

# Disable swapoff
swapoff -a

# Network configuration
modprobe overlay
modprobe br_netfilter

tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sysctl --system

## Setup CRI
wget --quiet https://github.com/containerd/containerd/releases/download/v1.7.0/containerd-1.7.0-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.7.0-linux-amd64.tar.gz
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl daemon-reload
systemctl enable --now containerd

# Pull required images
kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock

# Initialise kubeadm
kubeadm init \
  --cri-socket unix:///run/containerd/containerd.sock

echo -e "To use cluster with default user, execute these commands with default user:
          mkdir -p $HOME/.kube
          sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
          sudo chown $(id -u):$(id -g) $HOME/.kube/config"
 
 # Setup K8s network plugin
 kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
 kubectl taint nodes --all node-role.kubernetes.io/control-plane-
