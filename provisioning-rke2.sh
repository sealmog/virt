#!/bin/bash

set -e

create_dir() {
    if [[ -d "$1" ]]; then
        echo "Directory '$1' exists."
    else
        mkdir -p "$1"
    fi
}

rke2_pre() {

RKE2_ETC=/etc/rancher/rke2
create_dir "${RKE2_ETC}"

RKE2_DATA=/data/rancher/rke2
create_dir "${RKE2_DATA}"

KUBE_AUDIT=/var/log/kube-audit
create_dir "${KUBE_AUDIT}"

if "${FIRST}" ; then
cat <<EOF >> /etc/rancher/rke2/config.yaml
token: ${TOKEN}
tls-san:
  - ${RCH}
EOF
else
cat <<EOF >> /etc/rancher/rke2/config.yaml
token: ${TOKEN}
server: https://${RCH}:9345
tls-san:
  - ${RCH}
EOF
fi

cat <<EOF >> /etc/profile.d/rke2.sh
#!/bin/bash
################################################################################
#                                                                              #
#    Set envvars for rke2 tools (crictl, kubectl)                              #
#                                                                              #
################################################################################

# Add /data/rancher/rke2/bin to the path for sh compatible users

if [ -z "${PATH-}" ] ; then
    export PATH=/data/rancher/rke2/bin
elif ! echo "${PATH}" | grep -q /data/rancher/rke2/bin ; then
    export PATH="${PATH}:/data/rancher/rke2/bin"
fi

# Add config for crictl

if ! echo "${CRI_CONFIG_FILE-}" | grep -q /data/rancher/rke2/agent/etc/crictl.yaml ; then
    export CRI_CONFIG_FILE=/data/rancher/rke2/agent/etc/crictl.yaml
fi

# Add config for kubectl

if ! echo "${KUBECONFIG-}" | grep -q /etc/rancher/rke2/rke2.yaml ; then
    export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
fi
EOF
}

rke2() {
    curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.30 sh -x -

    systemctl enable rke2-server.service
    systemctl start rke2-server.service
    systemctl status rke2-server.service
}

helm() {
    curl -sfL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -x -
}

run() {
    rke2_pre
    rke2
    helm
}

run
