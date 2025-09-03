#!/bin/bash

set -e

system() {
cat <<EOF | tee /etc/sysctl.d/11-k8s.conf
net.ipv4.ip_forward = 1
EOF

sysctl --system
}

kubectl() {
KUBERNETES_VERSION=v1.32

# This overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

dnf install -y kubectl --disableexcludes=kubernetes
}

helm() {
    curl -sfL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -x -

    ln -s /usr/local/bin/helm /usr/local/sbin/helm
}

run() {
    system
    kubectl
    helm
}

run
